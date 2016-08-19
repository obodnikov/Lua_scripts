-- ESP-01 GPIO Mapping
gpio0 = 4

power = 2
powerADC= 1
-- MQTT connect script with deep sleep
-- Remember to connect GPIO16 and RST to enable deep sleep

--############
--# Settings #
--############

--- MQTT ---
mqtt_broker_ip = "192.168.1.10"     
mqtt_broker_port = 8883
mqtt_username = "dacha11"
mqtt_password = "qwerty"
mqtt_client_id = "sensor"

--- WIFI ---
wifi_SSID = "dacha11"
wifi_password = "paradox1234567"
-- wifi.PHYMODE_B 802.11b, More range, Low Transfer rate, More current draw
-- wifi.PHYMODE_G 802.11g, Medium range, Medium transfer rate, Medium current draw
-- wifi.PHYMODE_N 802.11n, Least range, Fast transfer rate, Least current draw 
wifi_signal_mode = wifi.PHYMODE_B
-- If the settings below are filled out then the module connects 
-- using a static ip address which is faster than DHCP and 
-- better for battery life. Blank "" will use DHCP.
-- My own tests show around 1-2 seconds with static ip
-- and 4+ seconds for DHCP
client_ip=""
client_netmask=""
client_gateway=""

--- INTERVAL ---
-- In milliseconds. Remember that the sensor reading, 
-- reboot and wifi reconnect takes a few seconds
time_between_sensor_readings = 60000

--################
--# END settings #
--################

-- Setup MQTT client and events
m = mqtt.Client(client_id, 120, username, password)
temperature = 0
humidity = 0

-- Connect to the wifi network
wifi.setmode(wifi.STATION) 
wifi.setphymode(wifi_signal_mode)
wifi.sta.config(wifi_SSID, wifi_password) 
wifi.sta.connect()
if client_ip ~= "" then
    wifi.sta.setip({ip=client_ip,netmask=client_netmask,gateway=client_gateway})
    pl = "/dacha11/sensors/"..wifi.sta.getmac()
end


gpio.mode(power,gpio.OUTPUT)
gpio.write(power,gpio.LOW)
gpio.mode(powerADC,gpio.OUTPUT)
gpio.write(powerADC,gpio.LOW)




-- DHT22 sensor logic
function get_sensor_Data() 
  
t = require("ds18b20")
temperature = 0
humidity = 0

-- ESP-01 GPIO Mapping

gpio.write(power,gpio.HIGH)
gpio.write(powerADC,gpio.HIGH)

tmr.delay(1000000)

t.setup(gpio0)
addrs = t.addrs()
if (addrs ~= nil) then
  print("Total DS18B20 sensors: "..table.getn(addrs))
end

for i=1,100 do
  humidity = humidity + adc.read(0)
  tmr.delay(100000)
end

humidity = humidity / 100

temperature = t.read()
tmr.delay(1000000)
temperature = t.read()

    t = nil
    ds18b20 = nil
    package.loaded["ds18b20"]=nil

    gpio.write(power,gpio.LOW)
    gpio.write(powerADC,gpio.LOW)
end

function loop() 
    if wifi.sta.status() == 5 then
        -- Stop the loop
        tmr.stop(0)
        m:connect( mqtt_broker_ip , mqtt_broker_port, 0, function(conn)
            print("Connected to MQTT")
            print("  IP: ".. mqtt_broker_ip)
            print("  Port: ".. mqtt_broker_port)
            print("  Client ID: ".. mqtt_client_id)
            print("  Username: ".. mqtt_username)
            -- Get sensor data
            get_sensor_Data() 
            m:publish(pl.."/temp",temperature, 0, 0, function(conn)
                m:publish(pl.."/humidity",humidity, 0, 0, function(conn)
                    print("Going to deep sleep for "..(time_between_sensor_readings/1000).." seconds")
                    node.dsleep(time_between_sensor_readings*1000)             
                end)          
            end)
        end )
    else
        print("Connecting...")
    end
end
        
tmr.alarm(0, 100, 1, function() loop() end)

-- ESP-01 GPIO Mapping
gpio0 = 4

power = 2
powerADC= 5
DHT = 1
gpio.mode(power,gpio.OUTPUT)
gpio.write(power,gpio.LOW)
gpio.mode(powerADC,gpio.OUTPUT)
gpio.write(powerADC,gpio.LOW)

mqtt_connect = 0

tmr.delay(1000000)


wifi.setmode(wifi.STATION)
--modify according your wireless router settings
wifi.sta.config("dacha11","paradox1234567")
-- wifi.setphymode(wifi.PHYMODE_N)
wifi.sta.connect()



function getSensors()
temp1 = 0

t = require("ds18b20")

gpio.write(power,gpio.HIGH)
gpio.write(powerADC,gpio.HIGH)


tmr.delay(800000)

t.setup(gpio0)
addrs = t.addrs()
if (addrs ~= nil) then
  print("Total DS18B20 sensors: "..table.getn(addrs))
end


tmr.delay(800000)

temp1 = t.read()
tmr.delay(800000)
temp1 = t.read()


-- Just read temperature


-- Get temperature of first detected sensor in Fahrenheit
-- print("Temperature: "..t.read(nil,t.F).."'F")

-- Query the second detected sensor, get temperature in Kelvin
-- if (table.getn(addrs) >= 2) then
--    print("Second sensor: "..t.read(addrs[1],t.K).."'K")
-- end

humidy=0

for i=1,100 do
  humidy = humidy + adc.read(0)
  tmr.delay(100000)
end

humidy = humidy / 100

print("Temperature: "..temp1.."'C")
print("Humidy: "..humidy)



gpio.write(power,gpio.LOW)
gpio.write(powerADC,gpio.LOW)


-- Don't forget to release it after use
t = nil
ds18b20 = nil
package.loaded["ds18b20"]=nil

end





-- m:on("message",dispatch )
-- Lua: mqtt:connect( host, port, secure, auto_reconnect, function(client) )

tmr.alarm(1, 1000, 1, function() 
  if wifi.sta.getip()== nil then 
      print("IP unavaiable, Waiting...") 
  else 
      tmr.stop(1)
      print("Config done, IP is "..wifi.sta.getip())

      pl = "/dacha11/sensors/"..node.chipid()
    
--      getSensors()
    getSensors()

    statusDHT, tempDHT, humiDHT, temp_dec_DHT, humi_dec_DHT = dht.read(DHT)
    print("DHT Temperature:"..tempDHT..";".."Humidity:"..humiDHT)


m=mqtt.Client("sensor",60,"dacha11","qwerty")

m:on("connect",function(k) 
	print("connection "..node.heap()) 
 
	m:publish(pl,"hello",0,0, function()
	    m:publish(pl.."/humidy",humidy,0,0, function()
	        m:publish(pl.."/temp1",temp1,0,0, function()
                m:publish(pl.."/temp2",tempDHT,0,0, function()
                    m:publish(pl.."/humi2",humiDHT,0,0, function()
	                    print("Send all")              
                        print("Go to deep sleep")
                        node.dsleep(15*60*1000000)
                        end )
                    end )
	            end )
	        end ) 
	    end )

     
end )

m:on("offline", function(conn)
    print("disconnect to broker...")
    print(node.heap())
end)


m:connect("192.168.1.10",8883,0,1)

   end

end)






function listap(t) -- (SSID : Authmode, RSSI, BSSID, Channel)
    
    print("\n"..string.format("%32s","SSID").."\tBSSID\t\t\t\t  RSSI\t\tAUTHMODE\tCHANNEL")
    for ssid,v in pairs(t) do
        local authmode, rssi, bssid, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]+)")
        print(string.format("%32s",ssid).."\t"..bssid.."\t  "..rssi.."\t\t"..authmode.."\t\t\t"..channel)
    end

    local ssidList = loadConfig("ssidList.lua")

    if(ssidList) then
        for ssid,v in pairs(t) do
            for ssidP,passwd in pairs(ssidList) do
                
                if(ssidP == ssid) then
                    print("Connect to SSID: "..ssidP.."\tpassword: "..passwd)
                    wifi.sta.config(ssidP, passwd)
                end
            end
        end
    else
        print("Can not load the list of SSID")
    end
end

function loadConfig(f)
        local loaded = {}

        if file.exists(f) then
 
                file.open(f, 'r')

                local line = file.readline()
                
                while line do
                        local key, value = string.match(line,'\"(.*)\"=\"(.*)\"')

                        if key then 
                            loaded[key] = value
                        else
                            print("Error in pair")
                        end
                        line = file.readline()
                end
                file.close()
                return loaded
        else
                return nil
        end
end

wifi.setmode(wifi.STATION)
wifi.sta.getap(listap)


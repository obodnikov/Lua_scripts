srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local configWifiFile = "ssidList.lua"
        local ssidList = loadConfig(configWifiFile)

        
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        buf = buf.."<p align=\"center\"><font size=\"5\"><span style=\"font-family: \'Comic Sans MS\', cursive;\">Welcome to Mike&#39;s Sensor configuration</font></p>";
        buf = buf.."<p align=\"center\"><font size=\"3\"><span style=\"font-family: \'Comic Sans MS\', cursive;\">List of Wifi networks, configured on chip</span></font></p>";
        buf = buf.."<table align=\"left\" border=\"1\" cellpadding=\"1\" cellspacing=\"1\" style=\"width: 100%\"><tbody>";
 --       local _on,_off = "",""
 
        for ssidP,passwd in pairs(ssidList) do    
            buf = buf.."<tr><td>"..ssidP.."</td><td>"..passwd.."</td><td><a href=\"?removeSSID="..ssidP.."\"><button>Remove Network</button></a></tr>"
        end    

        buf = buf.."</tbody></table><p>&nbsp;</p>"
        
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)


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
print("\n")
print("ESP8266 Started")

wifi.setmode(wifi.STATION)

--init.lua, something like this


local exefile="Connect2WIFI"
countdown = 3
tmr.alarm(0,1000,1,function()
    print(countdown)
    countdown = countdown-1
    if countdown<1 then
        tmr.stop(0)
        countdown = nil
        local s,err
        if file.open(exefile..".lc") then
            file.close()
            s,err = pcall(function() dofile(exefile..".lc") end)
        else
            s,err = pcall(function() dofile(exefile..".lua") end)
        end
        if not s then print(err) end
    end
end)

exefile=nil
collectgarbage()
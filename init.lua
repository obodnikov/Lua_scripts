--init.lua, something like this
countdown = 3
tmr.alarm(0,1000,1,function()
    print(countdown)
    countdown = countdown-1
    if countdown<1 then
        tmr.stop(0)
        countdown = nil
        local s,err
        if file.open("test2.lc") then
            file.close()
            s,err = pcall(function() dofile("test2.lc") end)
        else
            s,err = pcall(function() dofile("test2.lua") end)
        end
        if not s then print(err) 

        end
    end
end)

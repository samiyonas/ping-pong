function love.conf(t)
    local factor = 80
    t.window.width = 16*factor 
    t.window.height = 9*factor

    t.modules.joystick = false
    t.modules.physics = false
end

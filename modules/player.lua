local player = {}

player.INIT = function(self)
    self.joystick = joysticks.create()
    self.joystick:setPos(Number2(Screen.Width / 2, Screen.Height / 2))
    Camera:SetModeFree()
    Camera.Rotation = Number3(math.pi/4, math.pi/4, 0)
    player.speed = 100

    return true
end

player.spawn = function(self)
    Player:SetParent(World)
    Player.ShadowCookie = 0
    Player.Tick = function(s)
        s.Position.Y = 0.5
        local dir = rotate45({player.joystick:getValues().X, player.joystick:getValues().Y})
        s.Motion = Number3(dir[1], 0, dir[2])*50*player.speed/100
        if dir[1] ~= 0 or dir[2] ~= 0 then
            s.Forward = Number3(dir[1], 0, dir[2])
        end

        Camera.Position = Player.Position + Number3(-50, 75, -50)
    end
end

return player
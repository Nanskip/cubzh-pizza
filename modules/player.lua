local player = {}

player.INIT = function(self)
    self.joystick = joysticks.create()
    self.joystick:setPos(Number2(Screen.Width / 2, Screen.Height / 2))
    Camera:SetModeFree()
    Camera.Rotation = Number3(math.pi/4, math.pi/4, 0)

    return true
end

player.spawn = function(self)
    Player:SetParent(World)
    Player.Tick = function(s)
        s.Position.Y = 0.5
        s.Velocity = Number3(player.joystick:getValues().X, 0, player.joystick:getValues().Y)

        Camera.Position = Player.Position + Number3(-50, 60, -50)
    end
end

return player
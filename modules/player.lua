local player = {}

player.INIT = function(self)
    self.joystick = joysticks.create()
    self.joystick:setPos(Number2(Screen.Width / 2, Screen.Height / 2))

    return true
end

player.spawn = function(self)
    Player:SetParent(World)
    Player.Tick = function(s)
        s.Position.Y = 0.5

        s.Position.X = s.Position.X + self.joystick:getValues()[1]
        s.Position.Z = s.Position.Z + self.joystick:getValues()[2]
    end
end

return player
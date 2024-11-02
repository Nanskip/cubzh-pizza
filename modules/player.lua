local player = {}

player.INIT = function(self)
    self.joystick = joysticks.create()
    self.joystick:setPos(Number2(Screen.Width / 2, Screen.Height / 2))
    self.button_timer = 0

    Camera:SetModeFree()
    Camera.Rotation = Number3(math.pi/4, math.pi/4, 0)
    player.speed = 100

    return true
end

player.spawn = function(self)
    Player:SetParent(World)
    Player.ShadowCookie = 0
    Player.Tick = function(s)
        s.Velocity.Y = 0
        s.Position.Y = 0.52
        local dir = rotate45({player.joystick:getValues().X, player.joystick:getValues().Y})
        s.Motion = Number3(dir[1], 0, dir[2])*30*player.speed/100
        if dir[1] ~= 0 or dir[2] ~= 0 then
            s.Forward = Number3(dir[1], 0, dir[2])
        end

        Camera.Position = Player.Position + Number3(-50, 75, -50)
        self:checkButtons()
    end
end

player.checkButtons = function(self)
    local ray = Ray(Player.Position, {0, -1, 0})
    local impact = ray:Cast(nil, Player)
    if impact ~= nil then
        self.button_timer = self.button_timer + _DELTA_TIME
        if self.button_timer > 1 then
            if impact.Object.coords ~= nil then
                map.OBJECTS[impact.Object.coords[1]][impact.Object.coords[2]]:checkMoney(_MONEY)
            end
        end
    else
        self.button_timer = 0
    end
end

return player
local interface = {}

function interface.INIT(self)
    return true
end

function interface.CREATE(self)
    log("Creating interface...")
    Camera.FOV = 50
    Screen.DidResize = function()
        self:UPDATE()
    end

    self:UPDATE()
end

function interface.UPDATE(self)
    local WIDTH_MUL = Screen.Width / 1080
    local HEIGHT_MUL = Screen.Height / 1920
    local SCREEN_MUL = math.min(WIDTH_MUL, HEIGHT_MUL)

    if player.joystick then
        player.joystick:setScale(2*SCREEN_MUL)
        player.joystick:setPos(Number2(Screen.Width/2 - player.joystick.shape.Width/2, Screen.Height/6 - player.joystick.shape.Height/2))
    end
end

return interface
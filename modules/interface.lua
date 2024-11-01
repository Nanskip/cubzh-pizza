local interface = {}

function interface.INIT(self)
    return true
end

function interface.CREATE(self)
    log("Creating interface...")
    ui = require("uikit")

    Camera.FOV = 30
    Screen.DidResize = function()
        self:UPDATE()
    end

    local etc = {}
    etc.screen_left = ui:createFrame()
    etc.screen_left.Color = { gradient="H", from=Color(255, 255, 255), to=Color(255, 255, 255)}
    etc.screen_right = ui:createFrame()

    self:UPDATE()
end

function interface.UPDATE(self)
    local WIDTH_MUL = Screen.Width / 1080
    local HEIGHT_MUL = Screen.Height / 1920
    local SCREEN_MUL = math.min(WIDTH_MUL, HEIGHT_MUL)
    local FOV_UPDATE = 60 * math.min(WIDTH_MUL, HEIGHT_MUL)
    Camera.FOV = FOV_UPDATE

    if player.joystick then
        player.joystick:setScale(3*SCREEN_MUL)
        player.joystick:setPos(Number2(Screen.Width/2 - player.joystick.shape.Width/2, Screen.Height/6 - player.joystick.shape.Height/2))
    end

    for i=-1, 1 do
        local ray = Ray(Camera.Position, Camera.Forward + Camera.Left*0.1 + Camera.Up*i*0.1)
        local impact = ray:Cast({1, 2})
        print(impact.Block)
    end
end
Pointer.Down = function( pointerEvent ) local ray = Ray(pointerEvent.Position, pointerEvent.Direction) local impact = ray:Cast({1, 2}) if impact.Block ~= nil then print("block hit:", impact.Block) end end
return interface
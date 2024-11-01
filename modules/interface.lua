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

    self.etc = {}
    self.etc.screen_left = ui:createFrame()
    self.etc.leftColors = {
        Color(255, 255, 255),
        Color(255, 255, 255),
        Color(255, 255, 255),
    }
    self.etc.screen_left.Color = { gradient="H", from=Color(255, 255, 255), to=Color(255, 255, 255)}
    self.etc.screen_right = ui:createFrame()

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
        if impact.Block.Color ~= nil then
            self.etc.leftColors[i+2] = Color(
                math.floor(lerp(self.etc.leftColors[i+2].R, impact.Block.Color.R, 0.1)),
                math.floor(lerp(self.etc.leftColors[i+2].G, impact.Block.Color.G, 0.1)),
                math.floor(lerp(self.etc.leftColors[i+2].B, impact.Block.Color.B, 0.1))
            )
        end
    end

    local leftColor = Color(
        math.floor((self.etc.leftColors[1].R + self.etc.leftColors[2].R + self.etc.leftColors[3].R)/3),
        math.floor((self.etc.leftColors[1].G + self.etc.leftColors[2].G + self.etc.leftColors[3].G)/3),
        math.floor((self.etc.leftColors[1].B + self.etc.leftColors[2].B + self.etc.leftColors[3].B)/3)
    )
    self.etc.screen_left.Color = { gradient="H", from=Color(68, 68, 68), to=leftColor}
    self.etc.screen_left.Width, self.etc.screen_left.Height = 100, 100
end

return interface
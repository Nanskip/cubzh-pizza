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
        Color(255, 255, 255),
        Color(255, 255, 255),
    }
    self.etc.screen_right = ui:createFrame()
    self.etc.rightColors = {
        Color(255, 255, 255),
        Color(255, 255, 255),
        Color(255, 255, 255),
        Color(255, 255, 255),
        Color(255, 255, 255),
    }

    self.Tick = LocalEvent:Listen(LocalEvent.Name.Tick, function(dt)
        interface:UPDATE_SIDES()
    end)

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
end

function interface.UPDATE_SIDES(self)
    for i=-2, 2 do
        local ray = Ray(Camera.Position, Camera.Forward + Camera.Left*0.1 + Camera.Up*i*0.1)
        local impact = ray:Cast({1, 2})
        if impact.Block.Color ~= nil then
            self.etc.leftColors[i+2] = Color(
                math.floor(lerp(self.etc.leftColors[i+3].R, impact.Block.Color.R, 0.1)),
                math.floor(lerp(self.etc.leftColors[i+3].G, impact.Block.Color.G, 0.1)),
                math.floor(lerp(self.etc.leftColors[i+3].B, impact.Block.Color.B, 0.1))
            )
        elseif impact.Object.Color ~= nil then
            self.etc.leftColors[i+2] = Color(
                math.floor(lerp(self.etc.leftColors[i+3].R, impact.Object.Color.R, 0.1)),
                math.floor(lerp(self.etc.leftColors[i+3].G, impact.Object.Color.G, 0.1)),
                math.floor(lerp(self.etc.leftColors[i+3].B, impact.Object.Color.B, 0.1))
            )
        end
    end

    local leftColor = Color(
        math.floor((self.etc.leftColors[1].R + self.etc.leftColors[2].R + self.etc.leftColors[3].R + self.etc.leftColors[4].R + self.etc.leftColors[5].R)/5),
        math.floor((self.etc.leftColors[1].G + self.etc.leftColors[2].G + self.etc.leftColors[3].G + self.etc.leftColors[4].G + self.etc.leftColors[5].G)/5),
        math.floor((self.etc.leftColors[1].B + self.etc.leftColors[2].B + self.etc.leftColors[3].B + self.etc.leftColors[4].B + self.etc.leftColors[5].B)/5)
    )
    self.etc.screen_left.Color = { gradient="H", from=Color(68, 68, 68), to=leftColor}
    self.etc.screen_left.Width, self.etc.screen_left.Height = (Screen.Width-Screen.Height*0.5625)/2, Screen.Height

    for i=-2, 2 do
        local ray = Ray(Camera.Position, Camera.Forward + Camera.Right*0.1 + Camera.Up*i*0.1)
        local impact = ray:Cast({1, 2})
        if impact.Block.Color ~= nil then
            self.etc.rightColors[i+2] = Color(
                math.floor(lerp(self.etc.rightColors[i+3].R, impact.Block.Color.R, 0.1)),
                math.floor(lerp(self.etc.rightColors[i+3].G, impact.Block.Color.G, 0.1)),
                math.floor(lerp(self.etc.rightColors[i+3].B, impact.Block.Color.B, 0.1))
            )
        elseif impact.Object.Color ~= nil then
            self.etc.rightColors[i+2] = Color(
                math.floor(lerp(self.etc.rightColors[i+2].R, impact.Object.Color.R, 0.1)),
                math.floor(lerp(self.etc.rightColors[i+2].G, impact.Object.Color.G, 0.1)),
                math.floor(lerp(self.etc.rightColors[i+2].B, impact.Object.Color.B, 0.1))
            )
        end
    end

    local rightColor = Color(
        math.floor((self.etc.rightColors[1].R + self.etc.rightColors[2].R + self.etc.rightColors[3].R + self.etc.rightColors[4].R + self.etc.rightColors[5].R)/5),
        math.floor((self.etc.rightColors[1].G + self.etc.rightColors[2].G + self.etc.rightColors[3].G + self.etc.rightColors[4].G + self.etc.rightColors[5].G)/5),
        math.floor((self.etc.rightColors[1].B + self.etc.rightColors[2].B + self.etc.rightColors[3].B + self.etc.rightColors[4].B + self.etc.rightColors[5].B)/5)
    )
    self.etc.screen_right.Color = { gradient="H", from=rightColor, to=Color(68, 68, 68)}
    self.etc.screen_right.Width, self.etc.screen_right.Height = (Screen.Width-Screen.Height*0.5625)/2, Screen.Height
    self.etc.screen_right.pos = Number2(Screen.Width - self.etc.screen_right.Width, 0)
end

return interface
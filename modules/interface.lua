local interface = {}

function interface.INIT(self)
    self.showMoney = 0

    return true
end

function interface.CREATE(self)
    log("Creating interface...")
    ui = require("uikit")

    Camera.FOV = 30
    Screen.DidResize = function()
        self:UPDATE()
        Timer(0.02, false, function()
            self:UPDATE()
        end)
    end

    self.etc = {}
    local function createSides()
        self.etc.screen_left = ui:createFrame()
        self.etc.leftColors = {
            Color(255, 255, 255),
            Color(255, 255, 255),
            Color(255, 255, 255),
        }
        self.etc.leftColor = Color(255, 255, 255)
    
        self.etc.screen_right = ui:createFrame()
        self.etc.rightColors = {
            Color(255, 255, 255),
            Color(255, 255, 255),
            Color(255, 255, 255),
        }
        self.etc.rightColor = Color(255, 255, 255)
    
        self.SideTick = LocalEvent:Listen(LocalEvent.Name.Tick, function(dt)
            self:UPDATE_SIDES()
            self:UPDATE_COINS()
        end)
    end createSides()

    self.money = {}
    self.money.frame = ui:createFrame()
    self.money.frame.Color = Color(255, 255, 255)
    self.money.text = ui:createText("")
    self.money.text.Color = Color(36, 16, 2)
    self.money.coin = ui:createShape(Shape(Items.voxels.pezh_coin))

    self:UPDATE()
end

function interface.UPDATE(self)
    local WIDTH_MUL = Screen.Width / 1080
    local HEIGHT_MUL = Screen.Height / 1920
    local SCREEN_MUL = math.min(WIDTH_MUL, HEIGHT_MUL)
    local FOV_UPDATE = 60 * math.min(WIDTH_MUL, HEIGHT_MUL)
    local SAFEAREA = math.max(0, (Screen.Width-Screen.Height*0.5625)/2)
    Camera.FOV = FOV_UPDATE

    if player.joystick then
        player.joystick:setScale(3*SCREEN_MUL)
        player.joystick:setPos(Number2(Screen.Width/2 - player.joystick.shape.Width/2, Screen.Height/6 - player.joystick.shape.Height/2))
    end
    interface:UPDATE_COINS()
end

function interface.UPDATE_COINS(self)
    local SAFEAREA = math.max(0, (Screen.Width-Screen.Height*0.5625)/2)
    self.showMoney = lerp(self.showMoney, _MONEY, 0.75)
    self.money.text.Text = "$" .. math.round(self.showMoney)
    
    self.money.frame.Width, self.money.frame.Height = self.money.text.Width + 20, self.money.text.Height + 10
    self.money.frame.pos = Number2(Screen.Width - self.money.frame.Width - 10 - SAFEAREA, Screen.Height - self.money.frame.Height - 10 - Screen.SafeArea.Top)
    self.money.text.pos = Number2(self.money.frame.pos.X + 15, self.money.frame.pos.Y + 5)
    self.money.coin.shape.Pivot = Number3(self.money.coin.shape.Width/2, self.money.coin.shape.Height/2, self.money.coin.shape.Depth/2)
    self.money.coin.shape.Rotation = Rotation(-math.pi/2, 0, 0)*Rotation(0, 0.1, 0)
    self.money.coin.pos = Number2(Screen.Width - self.money.frame.Width - 80 - SAFEAREA, self.money.frame.pos.Y + self.money.frame.Height/2)
end

function interface.UPDATE_SIDES(self)
    for i=-1, 1 do
        local ray = Ray(Camera.Position, Camera.Forward + Camera.Left*0.1 + Camera.Up*i*0.1)
        local impact = ray:Cast({1, 2})
        if impact.Block.Color ~= nil then
            self.etc.leftColors[i+2] = Color(
                math.floor(lerp(self.etc.leftColors[i+2].R, impact.Block.Color.R, 0.1)),
                math.floor(lerp(self.etc.leftColors[i+2].G, impact.Block.Color.G, 0.1)),
                math.floor(lerp(self.etc.leftColors[i+2].B, impact.Block.Color.B, 0.1))
            )
        elseif impact.Object.Color ~= nil then
            self.etc.leftColors[i+2] = Color(
                math.floor(lerp(self.etc.leftColors[i+2].R, impact.Object.Color.R, 0.1)),
                math.floor(lerp(self.etc.leftColors[i+2].G, impact.Object.Color.G, 0.1)),
                math.floor(lerp(self.etc.leftColors[i+2].B, impact.Object.Color.B, 0.1))
            )
        end
    end

    local leftColor = Color(
        math.floor((self.etc.leftColors[1].R + self.etc.leftColors[2].R + self.etc.leftColors[3].R)/3),
        math.floor((self.etc.leftColors[1].G + self.etc.leftColors[2].G + self.etc.leftColors[3].G)/3),
        math.floor((self.etc.leftColors[1].B + self.etc.leftColors[2].B + self.etc.leftColors[3].B)/3)
    )
    self.etc.leftColor = Color(
        math.floor(lerp(self.etc.leftColor.R, leftColor.R, 0.1)),
        math.floor(lerp(self.etc.leftColor.G, leftColor.G, 0.1)),
        math.floor(lerp(self.etc.leftColor.B, leftColor.B, 0.1))
    )
    self.etc.screen_left.Color = { gradient="H", from=Color(68, 68, 68), to=self.etc.leftColor}
    self.etc.screen_left.Width, self.etc.screen_left.Height = (Screen.Width-Screen.Height*0.5625)/2, Screen.Height

    for i=-1, 1 do
        local ray = Ray(Camera.Position, Camera.Forward + Camera.Right*0.1 + Camera.Up*i*0.1)
        local impact = ray:Cast({1, 2})
        if impact.Block.Color ~= nil then
            self.etc.rightColors[i+2] = Color(
                math.floor(lerp(self.etc.rightColors[i+2].R, impact.Block.Color.R, 0.1)),
                math.floor(lerp(self.etc.rightColors[i+2].G, impact.Block.Color.G, 0.1)),
                math.floor(lerp(self.etc.rightColors[i+2].B, impact.Block.Color.B, 0.1))
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
        math.floor((self.etc.rightColors[1].R + self.etc.rightColors[2].R + self.etc.rightColors[3].R)/3),
        math.floor((self.etc.rightColors[1].G + self.etc.rightColors[2].G + self.etc.rightColors[3].G)/3),
        math.floor((self.etc.rightColors[1].B + self.etc.rightColors[2].B + self.etc.rightColors[3].B)/3)
    )
    self.etc.rightColor = Color(
        math.floor(lerp(self.etc.rightColor.R, rightColor.R, 0.1)),
        math.floor(lerp(self.etc.rightColor.G, rightColor.G, 0.1)),
        math.floor(lerp(self.etc.rightColor.B, rightColor.B, 0.1))
    )
    self.etc.screen_right.Color = { gradient="H", from=self.etc.rightColor, to=Color(68, 68, 68)}
    self.etc.screen_right.Width, self.etc.screen_right.Height = (Screen.Width-Screen.Height*0.5625)/2, Screen.Height
    self.etc.screen_right.pos = Number2(Screen.Width - self.etc.screen_right.Width, 0)
end

return interface
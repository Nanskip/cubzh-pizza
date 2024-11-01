local map = {}

function map.INIT(self)
    return true
end

function map.create_room(self, position, scale, type)
    local room = {}
    if position == nil then
        position = {0, 0}
    end
    if scale == nil then
        scale = {1, 1}
    end
    if type == nil then
        type = "main"
    end

    room.floors = {}
    for x=1, scale[1] do
        room.floors[x] = {}
        for y=1, scale[2] do
            room.floors[x][y] = Shape(Items.voxels.oak_floor)
            room.floors[x][y].Position = (Number3(position[1], 0, position[2]) + Number3(x-1, 0, y-1))*16
            room.floors[x][y].Scale = 1/2
            room.floors[x][y]:SetParent(World)
        end
    end
    room.floor = Quad()
    room.floor:SetParent(World)
    room.floor.Rotation.X = math.pi/2
    room.floor.Position = Number3(position[1], 0, position[2])*16 + Number3(0, 0.51, 0)
    room.floor.Scale = Number3(scale[1], scale[2], 1)*16

    room.Remove = function(self)
        for x=1, #self.floors do
            for y=1, #self.floors[x] do
                self.floors[x][y]:SetParent(nil)
                self.floors[x][y] = nil
            end
            self.floors[x] = nil
        end
        self.floors = nil
        self.floor:SetParent(nil)
        self.floor = nil
    end

    return room
end

map.create_object = function(self, object, config)
    local defaultConfig = {
        position = {0, 0},
        scale = 1,
        rotation = Rotation(0, 0, 0),
        collision = PhysicsMode.StaticPerBlock,
    }

    local obj = {}
    for key, value in pairs(defaultConfig) do
        if config[key] == nil then
            config[key] = value
        end
    end

    obj.shape = Shape(object.shape)
    obj.shape:SetParent(World)
    obj.shape.Position = Number3(config.position[1], 0, config.position[2])*16 + Number3(0, -32, 0)
    obj.shape.Scale = config.scale
    obj.shape.Rotation = config.rotation
    obj.shape.Physics = config.collision

    obj.button = Quad()
    obj.button:SetParent(World)
    obj.button.Rotation.X = math.pi/2
    obj.button.Position = Number3(config.position[1], 0, config.position[2])*16 + Number3(0, 0.51, 0)
    obj.button.Scale = 16

    obj.button.text = Text(config.name)
    obj.button.text:SetParent(obj.button)
    obj.button.text.Position = Number3(config.position[1], 0, config.position[2])*16 + Number3(0, 0.52, 0)
    obj.button.text.Color = Color(0, 0, 0)

    obj.purchase = function(self)
        for i=1, 30 do
            Timer(0.016*i, false, function()
                self.shape.Position.Y = lerp(self.shape.Position.Y, 0, 0.1)
                self.button.text.Color.A = lerp(self.button.text.Color.A, 0, 0.01)
                self.button.Color.A = lerp(self.button.Color.A, 0, 0.01)
            end)
        end
        Timer(0.51, false, function()
            self.button.text:SetParent(nil)
            self.button.text = nil
            self.button:SetParent(nil)
            self.button = nil
        end)
    end
end

map.objects = {
    test = {
        name = "Test Object",
        cost = 50,
        shape = Items.voxels.toxic_barrel,
        action = function(self)
            log("Test Object triggered!")
        end
    }
}

return map
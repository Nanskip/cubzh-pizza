local map = {}

function map.INIT(self)
    return true
end

map.objects = {
    test = {
        name = "Test",
        cost = 50,
        shape = Items.voxels.toxic_barrel,
        action = function(self)
            log("Test Object triggered!")
        end
    }
}

map.rooms = {
    main = {
        position = {0, 0},
        scale = {7, 10},
        type = "main",
        
        objects = {
            {
                object = map.objects.test,
                config = {
                    position = {3, 3},
                }
            }
        }
    }
}

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
            room.floors[x][y].CollisionGroups = {2}
            room.floors[x][y].PhysicsMode = PhysicsMode.StaticPerBlock
        end
    end
    room.floor = Quad()
    room.floor:SetParent(World)
    room.floor.Color = Color(255, 255, 255, 0)
    room.floor.Rotation.X = math.pi/2
    room.floor.Position = Number3(position[1], 0, position[2])*16 + Number3(0, 0.51, 0)
    room.floor.Scale = Number3(scale[1], scale[2], 1)*16
    room.floor.CollisionGroups = {3}

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
    obj.shape.Position = Number3(config.position[1]+0.5, 0, config.position[2]+0.5)*16 + Number3(0, -32, 0)
    obj.shape.Pivot = Number3(obj.shape.Width/2, 0, obj.shape.Depth/2)
    obj.shape.Scale = config.scale
    obj.shape.Rotation = config.rotation
    obj.shape.Physics = config.collision

    obj.button = Quad()
    obj.button:SetParent(World)
    obj.button.Rotation.X = math.pi/2
    obj.button.Position = Number3(config.position[1], 0, config.position[2])*16 + Number3(0, 0.51, 0)
    obj.button.Scale = 16

    obj.button.text = Text()
    obj.button.text.Text = object.name
    obj.button.text:SetParent(World)
    obj.button.text.Position = Number3(config.position[1]+0.5, 0, config.position[2]+0.75)*16 + Number3(0, 0.52, 0)
    obj.button.text.Color = Color(0, 0, 0)
    obj.button.text.BackgroundColor = Color(0, 0, 0, 0)
    obj.button.text.Scale = 1.5
    obj.button.text.Rotation.X = math.pi/2

    obj.cost = {}
    obj.cost.text = Text()
    obj.cost.text.Text = "0/"..object.cost
    obj.cost.text:SetParent(World)
    obj.cost.text.Position = Number3(config.position[1]+0.5, 0, config.position[2]+0.5)*16 + Number3(0, 0.52, 0)
    obj.cost.text.Color = Color(0, 0, 0)
    obj.cost.text.BackgroundColor = Color(0, 0, 0, 0)
    obj.cost.text.Scale = 1
    obj.cost.text.Rotation.X = math.pi/2

    obj.cost.coin = Shape(Items.voxels.pezh_coin)
    obj.cost.coin:SetParent(World)
    obj.cost.coin.Physics = PhysicsMode.Disabled
    obj.cost.coin.Pivot = Number3(obj.cost.coin.Width/2, 0.5, obj.cost.coin.Depth/2)
    obj.cost.coin.Position = Number3(config.position[1]+0.5, 0, config.position[2]+0.25)*16 + Number3(0, 0.52, 0)
    obj.cost.coin.Scale = Number3(0.25, 0.1, 0.25)

    obj.purchase = function(self)
        for i=1, 60 do
            Timer(0.016*i, false, function()
                self.shape.Position.Y = easeOutBack(-32, 0, i*1.667)
                self.button.text.Color.A = math.floor(lerp(self.button.text.Color.A, 0, 0.04))
                self.button.Color.A = math.floor(lerp(self.button.Color.A, 0, 0.04))
                self.cost.text.Color.A = math.floor(lerp(self.cost.text.Color.A, 0, 0.04))
                self.cost.coin.Position.Y = lerp(self.cost.coin.Position.Y, -32, 0.05)
            end)
        end
        Timer(1.01, false, function()
            self.shape.Position.Y = 0
            self.button.text:SetParent(nil)
            self.button.text = nil
            self.button:SetParent(nil)
            self.button = nil
            self.cost.text:SetParent(nil)
            self.cost.text = nil
            self.cost.coin:SetParent(nil)
            self.cost.coin = nil
            self.cost = nil
        end)
    end

    return obj
end

map.INIT_ROOMS = function(self)
    self._ROOMS = {}
    for key, value in pairs(self.rooms) do
        self._ROOMS[key] = self:create_room(value.position, value.scale, value.type)
        for i=1, #value.objects do
            self:create_object(value.objects[i].object, value.objects[i].config)
        end
    end
end

return map
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
            log(self.name .. " Object triggered!")
        end,
        remove = function(self)
            log(self.name .. " Object removed!")
        end
    },
    checkout = {
        name = "Checkout",
        cost = 100,
        shape = Items.pratamacam.checkout_counter,
        action = function(self)
            log(self.name .. " Object triggered!")
            self.shape1 = Shape(Items.chocomatte.cash_register02)
            self.shape1:SetParent(self.shape)
            self.shape1.Position = self.shape.Position + Number3(10, 9, -4)
            self.shape1.Rotation.Y = -0.2
            self.shape1.Scale = 0.8
        end,
        remove = function(self)
            log(self.name .. " Object removed!")
            self.shape1:SetParent(nil)
            self.shape1 = nil
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
                    scale = 0.5
                }
            },
            {
                object = map.objects.test,
                config = {
                    position = {1, 3},
                    scale = 0.75,
                    cost = 25
                }
            },
            {
                object = map.objects.checkout,
                config = {
                    position = {5, 2},
                    scale = 0.5,
                    rotation = Rotation(0, math.pi/2, 0)
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
            room.floors[x][y].Physics = PhysicsMode.StaticPerBlock
        end
    end

    room.Remove = function(self)
        for x=1, #self.floors do
            for y=1, #self.floors[x] do
                self.floors[x][y]:SetParent(nil)
                self.floors[x][y] = nil
            end
            self.floors[x] = nil
        end
        self.floors = nil
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
    local OBJ_cost = object.cost
    if config.cost ~= nil then
        OBJ_cost = config.cost
    end

    obj.action = object.action
    obj.remove = object.remove
    obj.name = object.name

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
    obj.button.Physics = PhysicsMode.Trigger
    obj.button.Scale = 16
    obj.button.coords = {config.position[1], config.position[2]}

    obj.button.text = Text()
    obj.button.text.Font = Font.Noto
    obj.button.text.Text = object.name
    obj.button.text:SetParent(World)
    obj.button.text.Position = Number3(config.position[1]+0.5, 0, config.position[2]+0.75)*16 + Number3(0, 0.52, 0)
    obj.button.text.Color = Color(0, 0, 0)
    obj.button.text.BackgroundColor = Color(0, 0, 0, 0)
    obj.button.text.Scale = 1.5
    obj.button.text.Rotation.X = math.pi/2

    obj.cost = {}
    obj.cost.text = Text()
    obj.cost.text.Font = Font.Noto
    obj.cost.text.Text = "0/"..OBJ_cost
    obj.cost.text:SetParent(World)
    obj.cost.text.Position = Number3(config.position[1]+0.5, 0, config.position[2]+0.5)*16 + Number3(0, 0.52, 0)
    obj.cost.text.Color = Color(0, 0, 0)
    obj.cost.text.BackgroundColor = Color(0, 0, 0, 0)
    obj.cost.text.Scale = 1
    obj.cost.text.Rotation.X = math.pi/2
    obj.cost.num = OBJ_cost

    obj.cost.bar = Quad()
    obj.cost.bar:SetParent(World)
    obj.cost.bar.Color = Color(107, 255, 99)
    obj.cost.bar.Position = Number3(config.position[1]+0.5-0.35, 0, config.position[2]+0.5-0.1)*16 + Number3(0, 0.515, 0)
    obj.cost.bar.Scale = Number3(0, 0.2, 1)*16
    obj.cost.bar.Rotation.X = math.pi/2

    obj.cost.coin = Shape(Items.voxels.pezh_coin)
    obj.cost.coin:SetParent(World)
    obj.cost.coin.Physics = PhysicsMode.Disabled
    obj.cost.coin.Pivot = Number3(obj.cost.coin.Width/2, 0.5, obj.cost.coin.Depth/2)
    obj.cost.coin.Position = Number3(config.position[1]+0.5, 0, config.position[2]+0.25)*16 + Number3(0, 0.52, 0)
    obj.cost.coin.Scale = Number3(0.25, 0.1, 0.25)

    obj.purchase = function(self)
        if not self.purchased then
            self.addedMoney = 0
            for i=1, 60 do
                Timer(0.016*i, false, function()
                    self.addedMoney = lerp(self.addedMoney, self.cost.num, 0.1)
                    self.cost.bar.Scale.X = lerp(self.cost.bar.Scale.X, 0.7*16, 0.1)
                    self.cost.text.Text = math.round(self.addedMoney) .."/"..self.cost.num
                    self.cost.coin.Scale.Y = lerp(self.cost.coin.Scale.Y, 3, 0.05)
                end)

                Timer(0.016*i+1, false, function()
                    self.shape.Position.Y = easeOutBack(-32, 0, i*1.667)
                    self.button.text.Color.A = math.floor(lerp(self.button.text.Color.A, 0, 0.04))
                    self.button.Color.A = math.floor(lerp(self.button.Color.A, 0, 0.04))
                    self.cost.text.Color.A = math.floor(lerp(self.cost.text.Color.A, 0, 0.04))
                    self.cost.coin.Position.Y = lerp(self.cost.coin.Position.Y, -32, 0.05)
                    self.cost.bar.Color = Color(107, 255, 99, math.floor(lerp(self.cost.bar.Color.A, 0, 0.04)))
                end)
            end
            Timer(2.01, false, function()
                self.shape.Position.Y = 0
                self.button.text:SetParent(nil)
                self.button.text = nil
                self.button:SetParent(nil)
                self.button = nil
                self.cost.text:SetParent(nil)
                self.cost.text = nil
                self.cost.bar:SetParent(nil)
                self.cost.bar = nil
                self.cost.coin:SetParent(nil)
                self.cost.coin = nil
                self.cost.num = nil
                self.cost = nil

                self:action()
            end)
        end
        self.purchased = true
    end

    obj.checkMoney = function(self)
        if not self.purchased then
            if self.cost.num <= _MONEY then
                _MONEY = _MONEY - self.cost.num
                self:purchase()
            end
        end
    end

    return obj
end

map.INIT_ROOMS = function(self)
    self._ROOMS = {}
    self._OBJECTS = {}
    for key, value in pairs(self.rooms) do
        self._ROOMS[key] = self:create_room(value.position, value.scale, value.type)
        for i=1, #value.objects do
            if not self._OBJECTS[value.objects[i].config.position[1]] then self._OBJECTS[value.objects[i].config.position[1]] = {} end

            local cfg = value.objects[i].config
            local obj = value.objects[i].object

            self._OBJECTS[cfg.position[1]][cfg.position[2]] = self:create_object(obj, cfg)
        end
    end
end

return map
local map = {}

function map.INIT(self)
    return true
end

function map.create_room(self, position, scale, type)
    local room = {}
    if position == nil then
        position = Number3(0, 0, 0)
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
            room.floors[x][y].Position = position
            room.floors[x][y]:SetParent(World)
        end
    end
    room.floor = Quad()
    room.floor:SetParent(World)
    room.floor.Rotation.X = -math.pi/2
    room.floor.Position = position
    room.floor.Scale = Number3(scale[1], scale[2], 1)

    return room
end

return map
local game = {}

game.INIT = function(self)
    return true
end

game.SET_VARIABLES = function(self)
    log("Setting variables...")

    _MONEY = 100
end

game.START = function(self)
    self:SET_VARIABLES()
    interface:CREATE()
    map:INIT_ROOMS()
    player:spawn()

    log("Game started!")
end

return game
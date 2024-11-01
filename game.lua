local game = {}

game.INIT = function(self)
    return true
end

game.START = function(self)
    interface:CREATE()
    map:INIT_ROOMS()
    player:spawn()

    log("Game started!")
end

return game
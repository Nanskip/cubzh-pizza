local game = {}

game.INIT = function(self)
    return true
end

game.START = function(self)
    interface:CREATE()

    log("Game started!")
end

return game
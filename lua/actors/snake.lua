local Actor = require("actor")
local Slither = require("movements.slither")
local SnakeModel = require("models.snake")

local Snake = {}

function Snake.new(x, y, options)
    options = options or {}
    return Actor.new(x, y, Slither.new(options), SnakeModel.createVariant(options.variant))
end

return Snake

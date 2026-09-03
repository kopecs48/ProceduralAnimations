local Actor = require("actor")
local Quadruped = require("movements.quadruped")
local DogModel = require("models.dog")

local Dog = {}

function Dog.new(x, y, options)
    options = options or {}
    return Actor.new(x, y, Quadruped.new(options), DogModel.createVariant(options.variant))
end

return Dog

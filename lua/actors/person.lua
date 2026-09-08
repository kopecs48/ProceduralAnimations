local Actor = require("actor")
local Biped = require("movements.biped")
local PersonModel = require("models.person")

local Person = {}

function Person.new(x, y, options)
    options = options or {}
    options.marginTop = options.marginTop or 150
    return Actor.new(x, y, Biped.new(options), PersonModel.createVariant(options.variant))
end

return Person

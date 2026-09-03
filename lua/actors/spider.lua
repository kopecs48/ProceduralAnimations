local Actor = require("actor")
local Octopod = require("movements.octopod")
local SpiderModel = require("models.spider")

local Spider = {}

function Spider.new(x, y, options)
    options = options or {}
    return Actor.new(x, y, Octopod.new(options), SpiderModel.createVariant(options.variant))
end

return Spider

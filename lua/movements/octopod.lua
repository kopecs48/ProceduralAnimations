local Ground = require("movements.ground")

local Octopod = {}
Octopod.__index = Octopod
setmetatable(Octopod, { __index = Ground })

local function liftAt(phase)
    local lift = math.max(0, -math.cos(phase))
    return lift * lift * (3 - 2 * lift)
end

function Octopod.new(options)
    options = options or {}
    options.kind = "octopod"
    options.maxSpeed = options.maxSpeed or 175
    options.acceleration = options.acceleration or 9
    options.animationBaseRate = options.animationBaseRate or 5
    options.animationSpeedRate = options.animationSpeedRate or 0.055
    options.marginX = options.marginX or 42
    options.marginTop = options.marginTop or 42
    options.marginBottom = options.marginBottom or 42
    return setmetatable(Ground.new(options), Octopod)
end

function Octopod:getLegPose(side, pair)
    -- Alternating groups always keep four feet planted while four recover.
    local groupA = (side < 0 and pair % 2 == 1) or (side > 0 and pair % 2 == 0)
    local phase = self.phase + (groupA and 0 or math.pi)
    local stride = -math.sin(phase) * 6 * self.amount
    local lift = liftAt(phase) * 4 * self.amount
    return stride, lift
end

function Octopod:getBodyPulse()
    return math.abs(math.sin(self.phase * 2)) * 1.2 * self.amount
end

return Octopod

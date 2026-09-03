local Ground = require("movements.ground")

local Quadruped = {}
Quadruped.__index = Quadruped
setmetatable(Quadruped, { __index = Ground })

local function liftAt(phase)
    local lift = math.max(0, -math.cos(phase))
    return lift * lift * (3 - 2 * lift)
end

function Quadruped.new(options)
    options = options or {}
    options.kind = "quadruped"
    options.maxSpeed = options.maxSpeed or 225
    options.acceleration = options.acceleration or 7
    options.animationBaseRate = options.animationBaseRate or 4
    options.animationSpeedRate = options.animationSpeedRate or 0.05
    options.marginX = options.marginX or 48
    options.marginTop = options.marginTop or 58
    options.marginBottom = options.marginBottom or 28
    return setmetatable(Ground.new(options), Quadruped)
end

function Quadruped:getLegPose(leg)
    -- Diagonal pairs share a phase to produce a reusable trot gait.
    local paired = leg == "frontLeft" or leg == "rearRight"
    local phase = self.phase + (paired and 0 or math.pi)
    -- A planted paw travels backward relative to the body; during the lifted
    -- half of the cycle it swings forward to begin the next step.
    return -math.sin(phase) * 7 * self.amount, liftAt(phase) * 5 * self.amount
end

function Quadruped:getBob()
    return math.abs(math.sin(self.phase * 2)) * 1.5 * self.amount
end

return Quadruped

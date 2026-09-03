local Ground = require("movements.ground")

local Biped = {}
Biped.__index = Biped
setmetatable(Biped, { __index = Ground })

local function liftAt(phase)
    local lift = math.max(0, -math.cos(phase))
    return lift * lift * (3 - 2 * lift)
end

function Biped.new(options)
    options = options or {}
    options.kind = "biped"
    options.maxSpeed = options.maxSpeed or 205
    options.startYOffset = options.startYOffset or 55
    options.marginTop = options.marginTop or 132
    return setmetatable(Ground.new(options), Biped)
end

function Biped:getStride()
    return math.sin(self.phase) * 12 * self.amount
end

function Biped:getLegPose(side)
    local stride = self:getStride() * side
    local lift = liftAt(self.phase + (side > 0 and math.pi or 0)) * self.amount
    return stride, lift
end

function Biped:getArmSwing(side)
    return -side * self:getStride() * 0.72
end

function Biped:getVerticalArmDepth(side)
    local offset = side > 0 and math.pi or 0
    return math.sin(self.phase + offset) * 4 * self.amount
end

function Biped:getBob()
    return math.abs(math.sin(self.phase)) * 3 * self.amount
end

function Biped:getIdleBreath()
    return math.sin(self.elapsed * 2.2) * (1 - self.amount) * 1.2
end

return Biped

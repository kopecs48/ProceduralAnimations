local Slither = {}
Slither.__index = Slither
local TAU = math.pi * 2
local atan2 = math.atan2 or function(y, x) return math.atan(y, x) end

local function clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

local function normalized(x, y)
    local length = math.sqrt(x * x + y * y)
    if length < 0.0001 then return 0, 0, 0 end
    return x / length, y / length, length
end

local function rotateToward(currentX, currentY, targetX, targetY, amount)
    local currentAngle = atan2(currentY, currentX)
    local targetAngle = atan2(targetY, targetX)
    local difference = (targetAngle - currentAngle + math.pi) % TAU - math.pi
    local angle = currentAngle + difference * amount
    return math.cos(angle), math.sin(angle)
end

function Slither.new(options)
    options = options or {}
    return setmetatable({
        kind = "slither",
        directionX = 1,
        directionY = 0,
        facingDirection = "right",
        speed = 0,
        maxSpeed = options.maxSpeed or 185,
        turnSpeed = options.turnSpeed or 7,
        segmentSpacing = options.segmentSpacing or 11,
        segmentCount = options.segmentCount or 32,
        margin = options.margin or 24,
        elapsed = 0,
        segments = {},
    }, Slither)
end

function Slither:attach(actor)
    for index = 1, self.segmentCount do
        self.segments[index] = {
            x = actor.x - (index - 1) * self.segmentSpacing,
            y = actor.y,
        }
    end
end

function Slither:updateToward(actor, dt, targetX, targetY, width, height)
    local desiredX, desiredY, distance = normalized(targetX - actor.x, targetY - actor.y)
    if distance > 2 then
        local turn = 1 - math.exp(-self.turnSpeed * dt)
        self.directionX, self.directionY = rotateToward(
            self.directionX, self.directionY, desiredX, desiredY, turn
        )
    end

    local desiredSpeed = self.maxSpeed * clamp(distance / 100, 0, 1)
    self.speed = self.speed + (desiredSpeed - self.speed) * (1 - math.exp(-5 * dt))
    self:updateBody(actor, dt, width, height)
end

function Slither:updateDirected(actor, dt, x, y, moving, width, height)
    if moving then
        local turn = 1 - math.exp(-self.turnSpeed * dt)
        self.directionX, self.directionY = rotateToward(
            self.directionX, self.directionY, x, y, turn
        )
    end

    local desiredSpeed = moving and self.maxSpeed or 0
    self.speed = self.speed + (desiredSpeed - self.speed) * (1 - math.exp(-7 * dt))
    self:updateBody(actor, dt, width, height)
end

function Slither:updateBody(actor, dt, width, height)
    self.elapsed = self.elapsed + dt
    local margin = self.margin

    actor.x = clamp(actor.x + self.directionX * self.speed * dt, margin, width - margin)
    actor.y = clamp(actor.y + self.directionY * self.speed * dt, margin, height - margin)

    if actor.x <= margin and self.directionX < 0 then self.directionX = -self.directionX end
    if actor.x >= width - margin and self.directionX > 0 then self.directionX = -self.directionX end
    if actor.y <= margin and self.directionY < 0 then self.directionY = -self.directionY end
    if actor.y >= height - margin and self.directionY > 0 then self.directionY = -self.directionY end

    if self.speed > 8 then
        if math.abs(self.directionX) > math.abs(self.directionY) then
            self.facingDirection = self.directionX < 0 and "left" or "right"
        else
            self.facingDirection = self.directionY < 0 and "up" or "down"
        end
    end

    self.segments[1].x = actor.x
    self.segments[1].y = actor.y

    for index = 2, #self.segments do
        local leader = self.segments[index - 1]
        local segment = self.segments[index]
        local dx, dy = leader.x - segment.x, leader.y - segment.y
        local nx, ny, distance = normalized(dx, dy)
        if distance > 0 then
            segment.x = leader.x - nx * self.segmentSpacing
            segment.y = leader.y - ny * self.segmentSpacing
        end
    end
end

function Slither:getPose()
    return self
end

return Slither

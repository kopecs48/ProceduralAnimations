local Ground = {}
Ground.__index = Ground

local function clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

local function normalized(x, y)
    local length = math.sqrt(x * x + y * y)
    if length < 0.0001 then return 0, 0, 0 end
    return x / length, y / length, length
end

local function approach(current, target, sharpness, dt)
    return current + (target - current) * (1 - math.exp(-sharpness * dt))
end

function Ground.new(options)
    options = options or {}
    return setmetatable({
        kind = options.kind or "ground",
        maxSpeed = options.maxSpeed or 200,
        acceleration = options.acceleration or 8,
        animationBaseRate = options.animationBaseRate or 3,
        animationSpeedRate = options.animationSpeedRate or 0.045,
        startYOffset = options.startYOffset or 0,
        marginX = options.marginX or 34,
        marginTop = options.marginTop or 34,
        marginBottom = options.marginBottom or 22,
        velocityX = 0,
        velocityY = 0,
        facing = 1,
        facingDirection = options.facingDirection or "right",
        phase = 0,
        elapsed = 0,
        amount = 0,
    }, Ground)
end

function Ground:attach(actor)
    actor.y = actor.y + self.startYOffset
end

function Ground:updateVelocity(dt, desiredX, desiredY)
    self.velocityX = approach(self.velocityX, desiredX, self.acceleration, dt)
    self.velocityY = approach(self.velocityY, desiredY, self.acceleration, dt)

    local directionX, directionY, speed = normalized(self.velocityX, self.velocityY)
    if speed > 8 then
        if math.abs(directionX) > math.abs(directionY) then
            self.facing = directionX < 0 and -1 or 1
            self.facingDirection = directionX < 0 and "left" or "right"
        else
            self.facingDirection = directionY < 0 and "up" or "down"
        end
    end

    self.amount = approach(self.amount, clamp(speed / self.maxSpeed, 0, 1), 10, dt)
    self.phase = self.phase + dt * (self.animationBaseRate + speed * self.animationSpeedRate)
    self.elapsed = self.elapsed + dt
end

function Ground:updatePosition(actor, dt, width, height)
    actor.x = clamp(actor.x + self.velocityX * dt, self.marginX, width - self.marginX)
    actor.y = clamp(actor.y + self.velocityY * dt, self.marginTop, height - self.marginBottom)
end

function Ground:updateToward(actor, dt, targetX, targetY, width, height)
    local dx, dy, distance = normalized(targetX - actor.x, targetY - actor.y)
    local speed = self.maxSpeed * clamp((distance - 12) / 90, 0, 1)
    self:updateVelocity(dt, dx * speed, dy * speed)
    self:updatePosition(actor, dt, width, height)
end

function Ground:updateDirected(actor, dt, x, y, moving, width, height)
    local speed = moving and self.maxSpeed or 0
    self:updateVelocity(dt, x * speed, y * speed)
    self:updatePosition(actor, dt, width, height)
end

function Ground:getPose()
    return self
end

return Ground

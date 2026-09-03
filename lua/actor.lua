local Actor = {}
Actor.__index = Actor

function Actor.new(x, y, movement, model)
    assert(movement and movement.attach, "an actor needs a movement module")
    assert(model and model.draw, "an actor needs a visual model")
    assert(not model.movementKind or model.movementKind == movement.kind,
        (model.name or "model") .. " requires " .. tostring(model.movementKind) .. " movement")

    local self = setmetatable({
        x = x,
        y = y,
        movement = movement,
        model = model,
        name = model.name or "ACTOR",
    }, Actor)

    movement:attach(self)
    return self
end

function Actor:updateToward(dt, targetX, targetY, width, height)
    self.movement:updateToward(self, dt, targetX, targetY, width, height)
end

function Actor:updateDirected(dt, x, y, moving, width, height)
    self.movement:updateDirected(self, dt, x, y, moving, width, height)
end

function Actor:draw()
    self.model.draw(self, self.movement:getPose())
end

return Actor

local SnakeModel = { movementKind = "slither" }
local TAU = math.pi * 2
local atan2 = math.atan2 or function(y, x) return math.atan(y, x) end
local variant = "normal"
local palettes = {
    normal = {
        body = { 0.09, 0.42, 0.29 }, stripe = { 0.035, 0.12, 0.07 },
        spot = { 0.39, 0.88, 0.48, 0.45 }, highlight = { 0.55, 1.0, 0.65, 0.18 },
        head = { 0.10, 0.52, 0.33 }, headLight = { 0.48, 0.94, 0.55, 0.32 },
        eye = { 0.92, 0.93, 0.67 }, pupil = { 0.025, 0.035, 0.03 }, tongue = { 0.95, 0.25, 0.38 },
    },
    zombie = {
        body = { 0.25, 0.36, 0.18 }, stripe = { 0.05, 0.08, 0.025 },
        spot = { 0.46, 0.22, 0.18, 0.65 }, highlight = { 0.64, 0.75, 0.38, 0.14 },
        head = { 0.31, 0.43, 0.20 }, headLight = { 0.52, 0.62, 0.31, 0.30 },
        eye = { 0.70, 0.68, 0.39 }, pupil = { 0.82, 0.10, 0.08 }, tongue = { 0.48, 0.12, 0.18 },
    },
    skeleton = {
        body = { 0.72, 0.70, 0.58 }, stripe = { 0.16, 0.16, 0.13 },
        spot = { 0.04, 0.05, 0.055, 0.75 }, highlight = { 1.0, 0.97, 0.80, 0.24 },
        head = { 0.82, 0.80, 0.66 }, headLight = { 1.0, 0.96, 0.78, 0.34 },
        eye = { 0.04, 0.05, 0.055 }, pupil = { 0.04, 0.05, 0.055 }, tongue = { 0.55, 0.50, 0.40 },
    },
}
local colors = palettes.normal

local function bodyRadius(index, count)
    local progress = (index - 1) / (count - 1)
    local headBlend = math.min(index / 5, 1)
    return (13.5 * headBlend) * (1 - progress * 0.78) + 1.5
end

local function drawBody(pose)
    for index = #pose.segments, 1, -1 do
        local segment = pose.segments[index]
        local radius = bodyRadius(index, #pose.segments)
        if variant == "skeleton" then radius = math.max(2.4, radius * 0.55) end
        local stripe = math.sin(index * 1.55) * 0.5 + 0.5
        love.graphics.setColor(
            colors.body[1] + stripe * colors.stripe[1],
            colors.body[2] + stripe * colors.stripe[2],
            colors.body[3] + stripe * colors.stripe[3]
        )
        love.graphics.circle("fill", segment.x, segment.y, radius)
        if index % 4 == 0 and index > 3 then
            love.graphics.setColor(colors.spot)
            love.graphics.circle("fill", segment.x, segment.y, radius * 0.52)
        end

        if variant == "skeleton" and index % 2 == 0 and index < #pose.segments then
            local nextSegment = pose.segments[index + 1]
            local dx, dy = segment.x - nextSegment.x, segment.y - nextSegment.y
            local length = math.max(0.001, math.sqrt(dx * dx + dy * dy))
            local px, py = -dy / length, dx / length
            love.graphics.setColor(colors.headLight)
            love.graphics.setLineWidth(2)
            love.graphics.line(
                segment.x - px * radius, segment.y - py * radius,
                segment.x + px * radius, segment.y + py * radius
            )
        end
    end

    love.graphics.setColor(colors.highlight)
    love.graphics.setLineWidth(2)
    for index = 4, #pose.segments - 4 do
        local a, b = pose.segments[index], pose.segments[index + 1]
        love.graphics.line(a.x - 2, a.y - 2, b.x - 2, b.y - 2)
    end
end

local function drawHead(actor, pose)
    local vectors = { left = {-1, 0}, right = {1, 0}, up = {0, -1}, down = {0, 1} }
    local facing = vectors[pose.facingDirection]
    local dx, dy = facing[1], facing[2]
    local px, py = -dy, dx
    local headX, headY = actor.x + dx * 3, actor.y + dy * 3

    love.graphics.push()
    love.graphics.translate(headX, headY)
    love.graphics.rotate(atan2(dy, dx))
    love.graphics.setColor(colors.head)
    love.graphics.ellipse("fill", 0, 0, 18, 14)
    love.graphics.setColor(colors.headLight)
    love.graphics.ellipse("fill", 2, -5, 12, 4)
    love.graphics.pop()

    for side = -1, 1, 2 do
        local eyeX, eyeY = headX + dx * 8 + px * side * 8, headY + dy * 8 + py * side * 8
        love.graphics.setColor(colors.eye)
        love.graphics.circle("fill", eyeX, eyeY, variant == "skeleton" and 4.5 or 3.7)
        love.graphics.setColor(colors.pupil)
        love.graphics.circle("fill", eyeX + dx * 1.2, eyeY + dy * 1.2, 1.8)
    end

    if math.sin(pose.elapsed * TAU * 1.4) > 0.58 then
        local startX, startY = headX + dx * 17, headY + dy * 17
        local endX, endY = startX + dx * 10, startY + dy * 10
        love.graphics.setColor(colors.tongue)
        love.graphics.setLineWidth(1.5)
        love.graphics.line(startX, startY, endX, endY)
        love.graphics.line(endX, endY, endX + dx * 4 + px * 3, endY + dy * 4 + py * 3)
        love.graphics.line(endX, endY, endX + dx * 4 - px * 3, endY + dy * 4 - py * 3)
    end
end

function SnakeModel.draw(actor, pose)
    assert(pose.kind == SnakeModel.movementKind, "snake model requires slither movement")
    drawBody(pose)
    drawHead(actor, pose)
end

local drawSnake = SnakeModel.draw

function SnakeModel.createVariant(requested)
    local selected = palettes[requested] and requested or "normal"
    local model = {
        name = (selected == "normal" and "" or selected:upper() .. " ") .. "SNAKE",
        movementKind = SnakeModel.movementKind,
    }
    model.draw = function(actor, pose)
        colors = palettes[selected]
        variant = selected
        drawSnake(actor, pose)
    end
    model.createVariant = SnakeModel.createVariant
    return model
end

return SnakeModel.createVariant("normal")

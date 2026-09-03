local SpiderModel = { movementKind = "octopod" }

local palettes = {
    normal = {
        outline = { 0.025, 0.025, 0.035 }, body = { 0.24, 0.16, 0.28 },
        bodyLight = { 0.48, 0.29, 0.52 }, leg = { 0.31, 0.20, 0.34 },
        rearLeg = { 0.17, 0.11, 0.20 }, eye = { 0.88, 0.18, 0.20 },
        marking = { 0.82, 0.38, 0.18 },
    },
    zombie = {
        outline = { 0.025, 0.035, 0.03 }, body = { 0.25, 0.36, 0.20 },
        bodyLight = { 0.45, 0.55, 0.28 }, leg = { 0.29, 0.40, 0.22 },
        rearLeg = { 0.16, 0.23, 0.13 }, eye = { 0.92, 0.72, 0.12 },
        marking = { 0.48, 0.16, 0.18 },
    },
    skeleton = {
        outline = { 0.03, 0.04, 0.045 }, body = { 0.72, 0.70, 0.59 },
        bodyLight = { 0.94, 0.91, 0.75 }, leg = { 0.80, 0.78, 0.65 },
        rearLeg = { 0.54, 0.53, 0.45 }, eye = { 0.03, 0.04, 0.045 },
        marking = { 0.20, 0.20, 0.18 },
    },
}

local function line(color, width, x1, y1, x2, y2)
    love.graphics.setColor(color)
    love.graphics.setLineWidth(width)
    love.graphics.line(x1, y1, x2, y2)
end

local function drawLeg(colors, variant, pose, side, pair, rootX, rootY, kneeX, kneeY, footX, footY)
    local _, lift = pose:getLegPose(side, pair)
    local shade = side > 0 and colors.leg or colors.rearLeg
    local width = variant == "skeleton" and 3 or 5
    kneeY = kneeY - lift * 0.3
    footY = footY - lift

    line(colors.outline, width + 4, rootX, rootY, kneeX, kneeY)
    line(colors.outline, width + 3, kneeX, kneeY, footX, footY)
    line(shade, width, rootX, rootY, kneeX, kneeY)
    line(shade, math.max(2, width - 1), kneeX, kneeY, footX, footY)
    love.graphics.setColor(shade)
    love.graphics.circle("fill", kneeX, kneeY, width * 0.65)
end

local function drawDetails(colors, variant, headX, headY, facingFront)
    if facingFront then
        love.graphics.setColor(colors.eye)
        local radius = variant == "skeleton" and 2.5 or 1.7
        for side = -1, 1, 2 do
            love.graphics.circle("fill", headX + 3, headY + side * 3, radius)
            love.graphics.circle("fill", headX + 6, headY + side * 2, radius * 0.8)
        end
    end

    if variant == "zombie" then
        line(colors.marking, 1.7, headX - 5, headY - 5, headX + 3, headY + 3)
    elseif variant == "skeleton" then
        line(colors.outline, 1.5, headX - 5, headY - 4, headX + 4, headY + 4)
    end
end

local function drawSide(actor, pose, colors, variant)
    local pulse = pose:getBodyPulse()
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.ellipse("fill", actor.x, actor.y + 3, 42, 8)
    love.graphics.push()
    love.graphics.translate(actor.x, actor.y - pulse)
    love.graphics.scale(pose.facing, 1)

    local roots = { -3, 1, 5, 9 }
    for side = -1, 1, 2 do
        for pair = 1, 4 do
            local stride = pose:getLegPose(side, pair)
            local fan = pair - 2.5
            local rootX = roots[pair]
            local rootY = -23 + side * 1.5
            local kneeX = rootX + fan * 8 + stride * 0.35
            local kneeY = -11 + side * 1.2
            local footX = rootX + fan * 13 + stride
            drawLeg(colors, variant, pose, side, pair, rootX, rootY, kneeX, kneeY, footX, 0)
        end
    end

    -- Drawing the body after every upper leg segment hides all attachment roots.
    love.graphics.setColor(colors.outline)
    love.graphics.ellipse("fill", -14, -28, 22, 17)
    love.graphics.setColor(colors.body)
    love.graphics.ellipse("fill", -14, -29, 18, 13)
    love.graphics.setColor(colors.marking)
    love.graphics.polygon("fill", -20, -35, -10, -29, -20, -23, -15, -29)

    love.graphics.setColor(colors.outline)
    love.graphics.circle("fill", 5, -27, 15)
    love.graphics.setColor(colors.bodyLight)
    love.graphics.circle("fill", 5, -28, 11)

    love.graphics.setColor(colors.outline)
    love.graphics.ellipse("fill", 19, -29, 10, 9)
    love.graphics.setColor(colors.bodyLight)
    love.graphics.ellipse("fill", 19, -30, 7, 6)
    drawDetails(colors, variant, 19, -30, true)
    love.graphics.pop()
end

local function drawVertical(actor, pose, colors, variant)
    local facingDown = pose.facingDirection == "down"
    local pulse = pose:getBodyPulse()
    local abdomenY = facingDown and -36 or -21
    local thoraxY = -28
    local headY = facingDown and -16 or -41

    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.ellipse("fill", actor.x, actor.y + 3, 35, 8)
    love.graphics.push()
    love.graphics.translate(actor.x, actor.y - pulse)

    for side = -1, 1, 2 do
        for pair = 1, 4 do
            local stride = pose:getLegPose(side, pair)
            local depth = pair - 2.5
            local rootX = side * 7
            local rootY = thoraxY + depth * 2
            local kneeX = side * (16 + math.abs(depth) * 2)
            local kneeY = -13 + depth * 2 + stride * 0.2
            local footX = side * (28 + math.abs(depth) * 2)
            local footY = depth * 3 + stride * 0.35
            drawLeg(colors, variant, pose, side, pair, rootX, rootY, kneeX, kneeY, footX, footY)
        end
    end

    love.graphics.setColor(colors.outline)
    love.graphics.ellipse("fill", 0, abdomenY, 18, 16)
    love.graphics.setColor(colors.body)
    love.graphics.ellipse("fill", 0, abdomenY - 1, 14, 12)
    love.graphics.setColor(colors.marking)
    love.graphics.polygon("fill", -6, abdomenY - 5, 0, abdomenY, 6, abdomenY - 5, 0, abdomenY + 5)

    love.graphics.setColor(colors.outline)
    love.graphics.circle("fill", 0, thoraxY, 15)
    love.graphics.setColor(colors.bodyLight)
    love.graphics.circle("fill", 0, thoraxY - 1, 11)

    love.graphics.setColor(colors.outline)
    love.graphics.ellipse("fill", 0, headY, 10, 8)
    love.graphics.setColor(colors.bodyLight)
    love.graphics.ellipse("fill", 0, headY - 1, 7, 5)

    if facingDown then
        -- Rotate the side-oriented face details into a front-facing arrangement.
        love.graphics.setColor(colors.eye)
        local radius = variant == "skeleton" and 2.5 or 1.7
        for side = -1, 1, 2 do
            love.graphics.circle("fill", side * 3, headY + 1, radius)
            love.graphics.circle("fill", side * 2, headY + 4, radius * 0.8)
        end
    elseif variant == "skeleton" then
        line(colors.outline, 1.5, -5, headY - 3, 4, headY + 3)
    end
    love.graphics.pop()
end

function SpiderModel.createVariant(requested)
    local selected = palettes[requested] and requested or "normal"
    local model = {
        name = (selected == "normal" and "" or selected:upper() .. " ") .. "SPIDER",
        movementKind = SpiderModel.movementKind,
    }
    model.draw = function(actor, pose)
        assert(pose.kind == SpiderModel.movementKind, "spider model requires octopod movement")
        local colors = palettes[selected]
        if pose.facingDirection == "left" or pose.facingDirection == "right" then
            drawSide(actor, pose, colors, selected)
        else
            drawVertical(actor, pose, colors, selected)
        end
    end
    model.createVariant = SpiderModel.createVariant
    return model
end

return SpiderModel.createVariant("normal")

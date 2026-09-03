local PersonModel = { movementKind = "biped" }
local variant = "normal"

local palettes = {}
palettes.normal = {
    outline = { 0.025, 0.04, 0.055 }, skin = { 0.82, 0.55, 0.36 },
    skinLight = { 0.96, 0.70, 0.48 }, shirt = { 0.20, 0.72, 0.66 },
    shirtLight = { 0.35, 0.90, 0.78 }, trousers = { 0.15, 0.23, 0.38 },
    rearTrousers = { 0.10, 0.16, 0.28 }, shoes = { 0.89, 0.38, 0.27 },
    hair = { 0.10, 0.065, 0.05 }, eye = { 0.035, 0.045, 0.05 },
}
palettes.zombie = {
    outline = { 0.025, 0.04, 0.035 }, skin = { 0.36, 0.50, 0.29 },
    skinLight = { 0.52, 0.66, 0.39 }, shirt = { 0.28, 0.34, 0.29 },
    shirtLight = { 0.39, 0.47, 0.36 }, trousers = { 0.20, 0.22, 0.25 },
    rearTrousers = { 0.12, 0.14, 0.16 }, shoes = { 0.30, 0.20, 0.16 },
    hair = { 0.08, 0.07, 0.045 }, eye = { 0.78, 0.12, 0.10 },
}
palettes.skeleton = {
    outline = { 0.035, 0.045, 0.05 }, skin = { 0.72, 0.70, 0.58 },
    skinLight = { 0.94, 0.91, 0.74 }, shirt = { 0.72, 0.70, 0.58 },
    shirtLight = { 0.94, 0.91, 0.74 }, trousers = { 0.72, 0.70, 0.58 },
    rearTrousers = { 0.54, 0.54, 0.47 }, shoes = { 0.72, 0.70, 0.58 },
    hair = { 0.035, 0.045, 0.05 }, eye = { 0.035, 0.045, 0.05 },
}
local colors = palettes.normal

local function line(color, width, x1, y1, x2, y2)
    love.graphics.setColor(color)
    love.graphics.setLineWidth(width)
    love.graphics.line(x1, y1, x2, y2)
end

local function joint(color, x, y, radius)
    love.graphics.setColor(color)
    love.graphics.circle("fill", x, y, radius)
end

local function drawLeg(pose, side, front)
    local hipX, hipY = side * 7, -49
    local swing, lift = pose:getLegPose(side)
    local footX = side * 7 + swing
    local footY = -2 - lift * 5
    local kneeBend = 1.5 * pose.amount + lift * 3
    local kneeX, kneeY = (hipX + footX) * 0.5 + kneeBend, (hipY + footY) * 0.5
    local shade = front and colors.trousers or colors.rearTrousers

    line(colors.outline, 13, hipX, hipY, kneeX, kneeY)
    line(colors.outline, 12, kneeX, kneeY, footX, footY)
    line(shade, 8, hipX, hipY, kneeX, kneeY)
    line(shade, 7, kneeX, kneeY, footX, footY)
    joint(shade, kneeX, kneeY, 4)
    line(colors.outline, 9, footX - 1, footY, footX + 9, footY)
    line(colors.shoes, 5, footX - 1, footY, footX + 9, footY)
end

local function drawArm(side, swing, front)
    local shoulderX, shoulderY = side * 15, -76
    local handX, handY = side * 17 + swing, -48 + math.abs(swing) * 0.15
    local elbowX, elbowY = (shoulderX + handX) * 0.5 + side * 4, -62
    local shirt = front and colors.shirtLight or colors.shirt
    line(colors.outline, 12, shoulderX, shoulderY, elbowX, elbowY)
    line(shirt, 7, shoulderX, shoulderY, elbowX, elbowY)
    line(colors.outline, 10, elbowX, elbowY, handX, handY)
    line(colors.skin, 6, elbowX, elbowY, handX, handY)
    joint(colors.skinLight, handX, handY, 4.5)
end

local function drawTorso(front)
    love.graphics.setColor(colors.outline)
    love.graphics.polygon("fill", -17, -82, 17, -82, 13, -47, -13, -47)
    love.graphics.setColor(colors.shirt)
    love.graphics.polygon("fill", -13, -79, 13, -79, 9, -50, -9, -50)
    love.graphics.setColor(colors.shirtLight)
    if front then
        love.graphics.polygon("fill", -10, -76, 10, -76, 8, -70, -8, -70)
    else
        love.graphics.setColor(colors.shirtLight[1], colors.shirtLight[2], colors.shirtLight[3], 0.35)
        love.graphics.rectangle("fill", -1, -76, 2, 23, 1, 1)
    end
    love.graphics.setColor(colors.outline)
    love.graphics.rectangle("fill", -14, -54, 28, 9, 4, 4)
    love.graphics.setColor(colors.trousers)
    love.graphics.rectangle("fill", -11, -52, 22, 6, 3, 3)
    if variant == "skeleton" then
        for y = -74, -58, 5 do
            line(colors.outline, 2, -8, y, 8, y)
        end
        line(colors.outline, 2, 0, -78, 0, -54)
    elseif variant == "zombie" then
        love.graphics.setColor(colors.outline)
        love.graphics.polygon("fill", -9, -51, -3, -58, 2, -50)
    end
end

local function drawHead(view)
    love.graphics.setColor(colors.outline)
    love.graphics.rectangle("fill", -6, -91, 12, 17, 5, 5)
    love.graphics.setColor(colors.skin)
    love.graphics.rectangle("fill", -4, -90, 8, 15, 4, 4)
    love.graphics.setColor(colors.outline)
    love.graphics.circle("fill", 0, -101, 20)
    love.graphics.setColor(colors.skinLight)
    love.graphics.circle("fill", 0, -101, 17)

    if variant == "skeleton" then
        if view ~= "up" then
            love.graphics.setColor(colors.eye)
            love.graphics.ellipse("fill", view == "side" and 7 or -6, -102, 4, 5)
            if view == "down" then love.graphics.ellipse("fill", 6, -102, 4, 5) end
            love.graphics.polygon("fill", -2, -97, 0, -94, 2, -97)
            for x = -6, 6, 3 do line(colors.outline, 1, x, -91, x, -87) end
        else
            line(colors.outline, 1.5, -5, -108, 2, -101)
        end
        return
    end

    if view == "up" then
        love.graphics.setColor(colors.hair)
        love.graphics.circle("fill", 0, -104, 17)
        love.graphics.circle("fill", 11, -112, 6)
        love.graphics.circle("fill", -10, -112, 6)
        love.graphics.setColor(colors.skin)
        love.graphics.ellipse("fill", 0, -91, 8, 3)
        return
    end

    love.graphics.setColor(colors.hair)
    love.graphics.arc("fill", 0, -104, 17.5, math.pi, math.pi * 2)
    love.graphics.circle("fill", 11, -112, 6)
    love.graphics.circle("fill", -10, -112, 6)
    love.graphics.setColor(colors.eye)
    if view == "down" then
        love.graphics.circle("fill", -6, -101, 2.1)
        love.graphics.circle("fill", 6, -101, 2.1)
        love.graphics.setColor(0.48, 0.20, 0.16)
        love.graphics.setLineWidth(1.6)
        love.graphics.arc("line", 0, -95, 4, 0.35, math.pi - 0.35)
    else
        love.graphics.circle("fill", 7, -101, 2.1)
        love.graphics.setColor(0.48, 0.20, 0.16)
        love.graphics.setLineWidth(1.6)
        love.graphics.arc("line", 8, -95, 4, 0.35, 1.7)
    end
    if variant == "zombie" then
        line(colors.eye, 1.5, -4, -111, 2, -106)
        line(colors.eye, 1.5, 2, -106, -1, -101)
    end
end

local function drawVerticalLeg(pose, side, front)
    local phase = pose.phase + (side > 0 and math.pi or 0)
    local _, lift = pose:getLegPose(side)
    local spread = math.abs(math.sin(phase)) * 1.5 * pose.amount
    local hipX, hipY = side * 7, -49
    local footX, footY = side * (7 + spread), -2 - lift * 5
    local kneeX, kneeY = (hipX + footX) * 0.5, (hipY + footY) * 0.5
    local shade = front and colors.trousers or colors.rearTrousers
    line(colors.outline, 13, hipX, hipY, kneeX, kneeY)
    line(colors.outline, 12, kneeX, kneeY, footX, footY)
    line(shade, 8, hipX, hipY, kneeX, kneeY)
    line(shade, 7, kneeX, kneeY, footX, footY)
    joint(shade, kneeX, kneeY, 4)
    line(colors.outline, 9, footX - 5, footY, footX + 5, footY)
    line(colors.shoes, 5, footX - 5, footY, footX + 5, footY)
end

local function drawVerticalArm(pose, side, front)
    local depth = pose:getVerticalArmDepth(side)
    local shoulderX, shoulderY = side * 15, -76
    local handX, handY = side * 18, -48 + depth
    local elbowX, elbowY = side * 19, -62 + depth * 0.5
    local shirt = front and colors.shirtLight or colors.shirt
    line(colors.outline, 12, shoulderX, shoulderY, elbowX, elbowY)
    line(shirt, 7, shoulderX, shoulderY, elbowX, elbowY)
    line(colors.outline, 10, elbowX, elbowY, handX, handY)
    line(colors.skin, 6, elbowX, elbowY, handX, handY)
    joint(colors.skinLight, handX, handY, 4.5)
end

local function drawVertical(pose)
    local frontLeg = math.sin(pose.phase) >= 0 and 1 or -1
    local rearLeg, frontArm, rearArm = -frontLeg, -frontLeg, frontLeg
    drawVerticalLeg(pose, rearLeg, false)
    drawVerticalArm(pose, rearArm, false)
    drawVerticalLeg(pose, frontLeg, true)
    drawTorso(pose.facingDirection == "down")
    drawVerticalArm(pose, frontArm, true)
    drawHead(pose.facingDirection)
end

local function drawSide(pose)
    local stride = pose:getStride()
    local frontLeg = stride >= 0 and 1 or -1
    local rearLeg = -frontLeg
    local armSwing = { [-1] = pose:getArmSwing(-1), [1] = pose:getArmSwing(1) }
    local frontArm = armSwing[1] >= armSwing[-1] and 1 or -1
    drawLeg(pose, rearLeg, false)
    drawArm(-frontArm, armSwing[-frontArm], false)
    drawLeg(pose, frontLeg, true)
    drawTorso(true)
    drawArm(frontArm, armSwing[frontArm], true)
    drawHead("side")
end

function PersonModel.draw(actor, pose)
    assert(pose.kind == PersonModel.movementKind, "person model requires biped movement")
    local bob = pose:getBob()
    local breathe = pose:getIdleBreath()
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.ellipse("fill", actor.x, actor.y + 3, 27 - bob, 7 - bob * 0.5)
    love.graphics.push()
    love.graphics.translate(actor.x, actor.y - bob + breathe)
    if pose.facingDirection == "up" or pose.facingDirection == "down" then
        drawVertical(pose)
    else
        love.graphics.scale(pose.facing, 1)
        drawSide(pose)
    end
    love.graphics.pop()
end

local drawPerson = PersonModel.draw

function PersonModel.createVariant(requested)
    local selected = palettes[requested] and requested or "normal"
    local model = {
        name = (selected == "normal" and "" or selected:upper() .. " ") .. "PERSON",
        movementKind = PersonModel.movementKind,
    }
    model.draw = function(actor, pose)
        colors = palettes[selected]
        variant = selected
        drawPerson(actor, pose)
    end
    model.createVariant = PersonModel.createVariant
    return model
end

return PersonModel.createVariant("normal")

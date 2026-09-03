local DogModel = { movementKind = "quadruped" }
local variant = "normal"

local palettes = {}
palettes.normal = {
    outline = { 0.035, 0.04, 0.045 },
    fur = { 0.72, 0.42, 0.20 },
    furLight = { 0.92, 0.65, 0.34 },
    furDark = { 0.38, 0.20, 0.12 },
    eye = { 0.025, 0.03, 0.03 },
}
palettes.zombie = {
    outline = { 0.03, 0.04, 0.035 }, fur = { 0.34, 0.48, 0.27 },
    furLight = { 0.52, 0.62, 0.34 }, furDark = { 0.18, 0.25, 0.16 },
    eye = { 0.82, 0.10, 0.08 },
}
palettes.skeleton = {
    outline = { 0.035, 0.045, 0.05 }, fur = { 0.75, 0.73, 0.61 },
    furLight = { 0.95, 0.92, 0.76 }, furDark = { 0.55, 0.54, 0.46 },
    eye = { 0.025, 0.03, 0.03 },
}
local colors = palettes.normal

local function line(color, width, x1, y1, x2, y2)
    love.graphics.setColor(color)
    love.graphics.setLineWidth(width)
    love.graphics.line(x1, y1, x2, y2)
end

local function drawSideLeg(pose, anchorX, leg, front)
    local stride, lift = pose:getLegPose(leg)
    local hipX, hipY = anchorX, -22
    local footX, footY = anchorX + stride, 0 - lift
    local kneeX, kneeY = (hipX + footX) * 0.5 + 2, -10 - lift * 0.25
    local shade = front and colors.fur or colors.furDark
    line(colors.outline, 11, hipX, hipY, kneeX, kneeY)
    line(colors.outline, 9, kneeX, kneeY, footX, footY)
    line(shade, 6, hipX, hipY, kneeX, kneeY)
    line(shade, 5, kneeX, kneeY, footX, footY)
    line(colors.outline, 6, footX - 2, footY, footX + 6, footY)
end

local function drawSide(actor, pose)
    local bob = pose:getBob()
    love.graphics.setColor(0, 0, 0, 0.22)
    love.graphics.ellipse("fill", actor.x, actor.y + 3, 43, 7)
    love.graphics.push()
    love.graphics.translate(actor.x, actor.y - bob)
    love.graphics.scale(pose.facing, 1)

    drawSideLeg(pose, -22, "rearLeft", false)
    drawSideLeg(pose, 20, "frontLeft", false)
    drawSideLeg(pose, -17, "rearRight", true)
    drawSideLeg(pose, 25, "frontRight", true)

    love.graphics.setColor(colors.outline)
    love.graphics.ellipse("fill", 0, -30, 39, 20)
    love.graphics.setColor(colors.fur)
    love.graphics.ellipse("fill", 0, -30, 35, 16)
    love.graphics.setColor(colors.furLight)
    love.graphics.ellipse("fill", 12, -34, 17, 7)
    if variant == "skeleton" then
        for x = -16, 14, 6 do
            line(colors.outline, 1.5, x, -39, x + 3, -23)
        end
        line(colors.outline, 2, -20, -31, 22, -31)
    elseif variant == "zombie" then
        love.graphics.setColor(colors.furDark)
        love.graphics.circle("fill", -9, -34, 6)
    end

    local wag = math.sin(pose.elapsed * 8) * 7
    line(colors.outline, 10, -34, -34, -49, -45 + wag)
    line(colors.furDark, 6, -34, -34, -49, -45 + wag)

    love.graphics.setColor(colors.outline)
    love.graphics.circle("fill", 34, -43, 18)
    love.graphics.setColor(colors.fur)
    love.graphics.circle("fill", 34, -43, 14)
    love.graphics.setColor(colors.furDark)
    love.graphics.polygon("fill", 25, -53, 20, -68, 32, -57)
    love.graphics.setColor(colors.furLight)
    love.graphics.ellipse("fill", 43, -39, 10, 7)
    love.graphics.setColor(colors.eye)
    love.graphics.circle("fill", 39, -47, variant == "skeleton" and 4 or 2.2)
    love.graphics.circle("fill", 51, -39, 2.5)
    love.graphics.pop()
end

local function drawFacingLeg(pose, side, isFront, leg, facingDown)
    local stride, lift = pose:getLegPose(leg)
    local near = isFront == facingDown
    local hipX = side * 12
    local hipY = near and -18 or -21
    -- Front and rear legs share a column in front/back views. Their vertical
    -- placement, shading, and alternating lift preserve the sense of depth.
    local footX = side * 14 + stride * 0.08
    local footY = (near and 0 or -4) - lift
    local shade = isFront and colors.fur or colors.furDark
    line(colors.outline, isFront and 10 or 9, hipX, hipY, footX, footY)
    line(shade, isFront and 6 or 5, hipX, hipY, footX, footY)
    love.graphics.setColor(colors.outline)
    love.graphics.ellipse("fill", footX, footY, 5, 3)
    love.graphics.setColor(shade)
    love.graphics.ellipse("fill", footX, footY, 3, 1.5)
end

local function drawFacingTail(pose, facingDown)
    local wag = math.sin(pose.elapsed * 8) * 8
    if facingDown then
        line(colors.outline, 10, 14, -32, 29 + wag * 0.35, -43)
        line(colors.furDark, 6, 14, -32, 29 + wag * 0.35, -43)
    else
        line(colors.outline, 10, 0, -20, wag, -3)
        line(colors.furDark, 6, 0, -20, wag, -3)
    end
end

local function drawVertical(actor, pose)
    local facingDown = pose.facingDirection == "down"
    local bob = pose:getBob()
    love.graphics.setColor(0, 0, 0, 0.22)
    love.graphics.ellipse("fill", actor.x, actor.y + 3, 31, 7)
    love.graphics.push()
    love.graphics.translate(actor.x, actor.y - bob)

    if facingDown then
        -- Looking toward the viewer: tail and rear legs sit behind the torso.
        drawFacingTail(pose, true)
        drawFacingLeg(pose, -1, false, "rearLeft", true)
        drawFacingLeg(pose, 1, false, "rearRight", true)
    else
        -- Looking away: the front legs are farther away and go behind the torso.
        drawFacingLeg(pose, -1, true, "frontLeft", false)
        drawFacingLeg(pose, 1, true, "frontRight", false)
    end

    love.graphics.setColor(colors.outline)
    love.graphics.ellipse("fill", 0, -30, 25, 20)
    love.graphics.setColor(colors.fur)
    love.graphics.ellipse("fill", 0, -30, 21, 16)
    if facingDown then
        love.graphics.setColor(colors.furLight)
        love.graphics.ellipse("fill", 0, -24, 11, 9)
    else
        love.graphics.setColor(colors.furDark)
        love.graphics.arc("fill", 0, -31, 20, 0.15, math.pi - 0.15)
    end

    if facingDown then
        drawFacingLeg(pose, -1, true, "frontLeft", true)
        drawFacingLeg(pose, 1, true, "frontRight", true)
    else
        -- The rump, tail, and rear legs are nearest in the up-facing view.
        drawFacingTail(pose, false)
        drawFacingLeg(pose, -1, false, "rearLeft", false)
        drawFacingLeg(pose, 1, false, "rearRight", false)
    end

    local headY = -48
    love.graphics.setColor(colors.outline)
    love.graphics.polygon("fill", -9, -53, -20, -62, -14, -40)
    love.graphics.polygon("fill", 9, -53, 20, -62, 14, -40)
    love.graphics.circle("fill", 0, headY, 17)
    love.graphics.setColor(colors.furDark)
    love.graphics.polygon("fill", -9, -53, -17, -59, -13, -42)
    love.graphics.polygon("fill", 9, -53, 17, -59, 13, -42)
    love.graphics.setColor(colors.fur)
    love.graphics.circle("fill", 0, headY, 13.5)

    if facingDown then
        love.graphics.setColor(colors.furLight)
        love.graphics.ellipse("fill", 0, headY + 7, 8, 6.5)
        love.graphics.setColor(colors.eye)
        local eyeSize = variant == "skeleton" and 3.8 or 2
        love.graphics.circle("fill", -5.5, headY - 1, eyeSize)
        love.graphics.circle("fill", 5.5, headY - 1, eyeSize)
        love.graphics.circle("fill", 0, headY + 10, 2.7)
    else
        love.graphics.setColor(colors.furDark)
        love.graphics.arc("fill", 0, headY - 1, 13, math.pi, math.pi * 2)
        love.graphics.setColor(colors.furLight[1], colors.furLight[2], colors.furLight[3], 0.45)
        love.graphics.rectangle("fill", -9, headY + 10, 18, 3, 1.5, 1.5)
    end
    if variant == "skeleton" then
        for x = -12, 12, 6 do line(colors.outline, 1.5, x, -34, x, -23) end
    elseif variant == "zombie" then
        line(colors.eye, 1.5, -7, headY - 9, 1, headY - 3)
    end
    love.graphics.pop()
end

function DogModel.draw(actor, pose)
    assert(pose.kind == DogModel.movementKind, "dog model requires quadruped movement")
    if pose.facingDirection == "up" or pose.facingDirection == "down" then
        drawVertical(actor, pose)
    else
        drawSide(actor, pose)
    end
end

local drawDog = DogModel.draw

function DogModel.createVariant(requested)
    local selected = palettes[requested] and requested or "normal"
    local model = {
        name = (selected == "normal" and "" or selected:upper() .. " ") .. "DOG",
        movementKind = DogModel.movementKind,
    }
    model.draw = function(actor, pose)
        colors = palettes[selected]
        variant = selected
        drawDog(actor, pose)
    end
    model.createVariant = DogModel.createVariant
    return model
end

return DogModel.createVariant("normal")

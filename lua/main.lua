local Snake = require("actors.snake")
local Person = require("actors.person")
local Dog = require("actors.dog")
local Spider = require("actors.spider")

local actorTypes = {
    person = Person,
    snake = Snake,
    dog = Dog,
    spider = Spider,
}

local actor
local actorKind = "person"
local actorVariant = "normal"
local actorVariants = { "normal", "zombie", "skeleton" }
local actorVariantIndex = 1
local controlMode = "mouse"
local uiFont
local titleFont

local palette = {
    background = { 0.035, 0.055, 0.075 },
    grid = { 0.10, 0.16, 0.19 },
    text = { 0.82, 0.91, 0.88 },
    muted = { 0.48, 0.61, 0.60 },
    accent = { 0.34, 0.91, 0.62 },
}

local function resetActor()
    local width, height = love.graphics.getDimensions()
    actor = actorTypes[actorKind].new(width * 0.5, height * 0.5, { variant = actorVariant })
end

function love.load()
    love.graphics.setDefaultFilter("linear", "linear")
    love.graphics.setLineStyle("smooth")
    love.graphics.setBackgroundColor(palette.background)

    uiFont = love.graphics.newFont(14)
    titleFont = love.graphics.newFont(22)
    resetActor()
end

local function wasdDirection()
    local x, y = 0, 0

    if love.keyboard.isDown("a") then x = x - 1 end
    if love.keyboard.isDown("d") then x = x + 1 end
    if love.keyboard.isDown("w") then y = y - 1 end
    if love.keyboard.isDown("s") then y = y + 1 end

    local length = math.sqrt(x * x + y * y)
    if length > 0 then
        x, y = x / length, y / length
    end

    return x, y, length > 0
end

function love.update(dt)
    -- Avoid large simulation jumps after dragging or pausing the window.
    dt = math.min(dt, 1 / 30)
    local width, height = love.graphics.getDimensions()

    if controlMode == "mouse" then
        local mouseX, mouseY = love.mouse.getPosition()
        actor:updateToward(dt, mouseX, mouseY, width, height)
    else
        local x, y, moving = wasdDirection()
        actor:updateDirected(dt, x, y, moving, width, height)
    end
end

local function drawGrid(width, height)
    love.graphics.setColor(palette.grid)
    love.graphics.setLineWidth(1)
    local spacing = 50
    for x = spacing, width, spacing do
        love.graphics.line(x, 0, x, height)
    end
    for y = spacing, height, spacing do
        love.graphics.line(0, y, width, y)
    end
end

local function drawMouseTarget()
    if controlMode ~= "mouse" then return end

    local x, y = love.mouse.getPosition()
    local pulse = 7 + math.sin(love.timer.getTime() * 4) * 2
    love.graphics.setColor(palette.accent[1], palette.accent[2], palette.accent[3], 0.65)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", x, y, pulse)
    love.graphics.line(x - 3, y, x + 3, y)
    love.graphics.line(x, y - 3, x, y + 3)
end

local function drawUi(width, height)
    love.graphics.setFont(titleFont)
    love.graphics.setColor(palette.text)
    love.graphics.print("PROCEDURAL " .. actor.name, 24, 20)

    love.graphics.setFont(uiFont)
    love.graphics.setColor(palette.muted)
    love.graphics.print("Mode", 26, 58)

    local label = controlMode == "mouse" and "MOUSE FOLLOW" or "WASD CONTROL"
    love.graphics.setColor(palette.accent)
    love.graphics.print(label, 76, 58)

    love.graphics.setColor(palette.muted)
    love.graphics.print("Variant", 26, 80)
    love.graphics.setColor(palette.accent)
    love.graphics.print(actorVariant:upper(), 88, 80)

    love.graphics.setColor(palette.muted)
    love.graphics.print("[M] mode  [H] person  [N] snake  [Q] dog  [8] spider  [V] variant  [R] reset  [Esc] quit", 26, height - 34)

    local hint = controlMode == "mouse" and "Move the pointer to lead the character" or "Use W A S D to steer"
    local hintWidth = uiFont:getWidth(hint)
    love.graphics.print(hint, width - hintWidth - 24, 27)
end

function love.draw()
    local width, height = love.graphics.getDimensions()
    drawGrid(width, height)
    drawMouseTarget()
    actor:draw()
    drawUi(width, height)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "tab" or key == "m" then
        controlMode = controlMode == "mouse" and "wasd" or "mouse"
    elseif key == "1" then
        controlMode = "mouse"
    elseif key == "2" then
        controlMode = "wasd"
    elseif key == "r" then
        resetActor()
    elseif key == "h" then
        actorKind = "person"
        resetActor()
    elseif key == "n" then
        actorKind = "snake"
        resetActor()
    elseif key == "q" then
        actorKind = "dog"
        resetActor()
    elseif key == "8" then
        actorKind = "spider"
        resetActor()
    elseif key == "v" then
        actorVariantIndex = actorVariantIndex % #actorVariants + 1
        actorVariant = actorVariants[actorVariantIndex]
        resetActor()
    end
end

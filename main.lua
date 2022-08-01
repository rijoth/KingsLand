Object = require 'lib.classic'
SceneryInit = require "lib.scenery"

local scenery = SceneryInit(
  {path = "menu", key = "menu"},
  {path = "game", key = "game"}
)

local canvas = nil
function love.load()
  -- for pixelart
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.graphics.setLineStyle("rough")
  canvas = love.graphics.newCanvas(320, 180) -- we draw in canvas and scale it to the window

  scenery:load()
end

function love.update(dt)
  scenery:update(dt)
end

function love.draw()
--  love.graphics.scale(2,2) -- scale game

--  draw to the canvas
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  scenery:draw()
  love.graphics.setCanvas()

  -- draw the canvas to screen
  love.graphics.setColor(1,1,1,1)
  love.graphics.setBlendMode('alpha', 'premultiplied')
  love.graphics.draw(canvas, 0, 0, 0, 2, 2) -- draw the canvas to the screen with 2x scale
  love.graphics.setBlendMode('alpha')
end

function love.keypressed(key)
  scenery:keypressed(key)
end

function love.keyreleased(key)
  scenery:keyreleased(key)
end

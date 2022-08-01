Cron = require "lib.cron" -- provides timer
Anim8 = require "lib.anim8"

local wf = require "lib.windfield"
local sti = require "lib.sti"
local Camera = require "lib.Camera"

require 'objects.actor'
require 'objects.player'
require 'objects.enemy'
require 'objects.snake'
require 'objects.box'

local game = {}

function game:load()
  -- attach a camera to the gameworld
  local w, h = 320, 180 -- game resolution
  self.camera = Camera(w/2, h/2, w, h)
  self.camera:setFollowStyle('PLATFORMER')
  self.camera:setBounds(0, 0, w * 3, h) -- set boundaries, camera won't move past this

  self.gravity = 200 --world gravity

  -- new box2d world
  self.world = wf.newWorld(0, self.gravity)
  self.world:setQueryDebugDrawing(true) -- for debugging, turn off

  self.map = sti('maps/test_map.lua')

  -- set collision classes to filter collisions
  game.world:addCollisionClass('Ground')
  game.world:addCollisionClass('Player')
  game.world:addCollisionClass('Wall')
  game.world:addCollisionClass('Enemy')
  game.world:addCollisionClass('Platform') --one-way platforms
  game.world:addCollisionClass('Ladder')
  game.world:addCollisionClass('Box', {ignores = {'Enemy'}})

  -- create ground
  self.grounds = {} -- this table contain all ground objects
  if self.map.layers["objects.ground"] then
    for _, obj in pairs(self.map.layers["objects.ground"].objects) do
      local ground = self.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
      ground:setType('static')
      ground:setFriction(2)
      ground:setCollisionClass('Ground')
      table.insert(self.grounds, ground)
    end
  end
  -- create wall
  self.walls = {} -- this table contain all wall objects
  if self.map.layers["objects.wall"] then
    for _, obj in pairs(self.map.layers["objects.wall"].objects) do
      local wall = self.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
      wall:setType('static')
      wall:setFriction(0)
      wall:setCollisionClass('Wall')
      table.insert(self.walls, wall)
    end

  end
 -- create one-way platforms
  self.platforms = {} -- this table contain all platform objects
  if self.map.layers["objects.platform"] then
    for _, obj in pairs(self.map.layers["objects.platform"].objects) do
      local platform = self.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
      platform:setType('static')
      platform.width = obj.width
      platform.height = obj.height
      platform:setFriction(2)
      platform:setCollisionClass('Platform')
      table.insert(self.platforms, platform)
    end
  end
  -- create ladders
  self.ladders = {} -- this table contain all ladder objects
  if self.map.layers["objects.ladder"] then
    for _, obj in pairs(self.map.layers["objects.ladder"].objects) do
      local ladder = self.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
      ladder:setType('static')
      ladder:setFriction(2)
      ladder:setCollisionClass('Ladder')
      table.insert(self.ladders, ladder)
    end
  end
 -- create boxes
  self.boxes = {} -- this table contain all box objects
  if self.map.layers["objects.box"] then
    for _, obj in pairs(self.map.layers["objects.box"].objects) do
      local box = Box(obj.x, obj.y, self.world)      --box:setType('static')
      table.insert(self.boxes, box)
    end
  end
-- create player
  if self.map.layers["objects.player"] then
    for _, obj in pairs(self.map.layers["objects.player"].objects) do
      obj.visible = false -- make tiled rectangle invisible
      self.player = Player(obj.x, obj.y, self.world)
    end
  end

-- create enemies
  self.enemies = {} -- contain all the enemies
  if self.map.layers["objects.enemy"] then
    for _, obj in pairs(self.map.layers["objects.enemy"].objects) do
      local enemy = Enemy(obj.x, obj.y, obj.name, self.world)
      table.insert(self.enemies, enemy)
    end
  end

end

function game:update(dt)
  -- update player
  self.player:update(dt)

  -- update enemies
  for _, enemy in pairs(self.enemies) do
    enemy:update(dt)
  end

  -- update Boxes
  for _, box in pairs(self.boxes) do
    box:update(dt)
  end

  self.world:update(dt)

  -- update camera and set it to follow player
  self.camera:update(dt)
  self.camera:follow(self.player.x, self.player.y)
end

function game:draw()

  -- set background color
  love.graphics.setBackgroundColor(love.math.colorFromBytes(93, 151, 141))

  -- draw everything inside camera:attach() and camera:detach()
  self.camera:attach()
--  for camera to work each tile layer has to be drawn individually
  self.map:drawLayer(self.map.layers["tiles.trees"])
  self.map:drawLayer(self.map.layers["tiles.leaves"])
  self.map:drawLayer(self.map.layers["tiles.ground"])
  self.map:drawLayer(self.map.layers["tiles.misc"])

 -- draw Boxes
  for _, box in pairs(self.boxes) do
    box:draw()
  end
  -- draw Enemy
  for _, enemy in pairs(self.enemies) do
    enemy:draw()
  end

  -- draw player
  self.player:draw()
  -- self.world:draw() --debugging
  self.camera:detach()
  --self.camera:draw() -- for debugging
end

function game:keypressed(key)
 self.player:keypressed(key)
end

function game:keyreleased(key)
  self.player:keyreleased(key)
end

return game

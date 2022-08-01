local anim8 = Anim8
local cron = Cron

Box = Actor:extend()

function Box:new(x, y, world)
  Box.super:new(x, y, world)
  self.w = 16
  self.h = 16
  self.world = world
  self.move_force = 180

  -- animation
  self.image = love.graphics.newImage('assets/images/box.png')

  --collider
  self.collider = self.world:newRectangleCollider(self.x, self.y, self.w, self.h)
  self.collider:setCollisionClass('Box')
  -- self.collider:setLinearDamping(4)
  -- self.collider:setFriction(2)
  self.collider:setObject(self)
  self.collider:setFixedRotation(true)
end

-- update function
function Box:update(dt)
    -- make sprite x & y cords same as collider
    self.x = self.collider:getX() - 8
    self.y = self.collider:getY() - 8
end

-- draw function
function Box:draw()
  love.graphics.draw(self.image, self.x, self.y)
end


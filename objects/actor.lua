Actor = Object:extend()

function Actor:new(x, y, world)
  self.x = x
  self.y = y
  self.world = world
end

function Actor:draw()
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end

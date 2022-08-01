-- an area2d like system from godot
Area = Object:extend()

function Area:new(x, y, w, h, val)
  self.x = x
  self.y = y
  self.w = w
  self.h = h
  self.enabled = val or true
end

function Area:update( x, y)
  self.x = x
  self.y = y
end

function Area:enable()
  self.enabled = true
end

function Area:disable()
  self.enabled = false
end

function Area:isEnabled()
  return self.enabled
end

function Area:checkCollision(x, y, w, h)
  return self.x < x + w and
         x < self.x + self.w and
         self.y < y + h and
         y < self.y + self.h
end

function Area:draw()
  if self.enabled then
    love.graphics.setColor(0, 1, 0, 0.5)
  else
    love.graphics.setColor(1, 0, 0, 0.5)
  end
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  love.graphics.setColor(1, 1, 1, 1)
end

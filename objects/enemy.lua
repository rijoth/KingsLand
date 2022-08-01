local cron = Cron

-- this will be the common hub for all enemies
require "objects.snake"
Enemy = Actor:extend()

function Enemy:new(x, y, type, world)
  Enemy.super:new(x, y, world)
  self.type = type
  self.health = 10
  -- spawn enemy based on the type
  if self.type == 'snake' then
    self.obj = Snake(self.x, self.y, self.world)
  end

  -- flip enemy movement direction using cron
 local function flip()
  self.obj:flip()
 end
 self.flip_timer = cron.every(5, flip) -- after 5 seconds flip movement

end

function Enemy:update(dt)
 self.obj:update(dt)
 self.flip_timer:update(dt)
end

function Enemy:draw()
  self.obj:draw()
end


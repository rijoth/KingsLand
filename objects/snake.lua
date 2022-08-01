local anim8 = Anim8
local cron = Cron

Snake = Actor:extend()

function Snake:new(x, y, world)
  Snake.super:new(x, y, world)
  self.w = 16
  self.h = 16
  self.world = world
  self.move_force = 180

  -- snake dir control variables
  local dir = {'left', 'right'}
  self.dir = math.random(#dir)
  if self.dir == 'left' then
    self.scale = -1
  else
    self.scale = 1
  end

  -- animation
  self.image = love.graphics.newImage('assets/images/snake.png')
  local g = anim8.newGrid(32, 32, self.image:getWidth(), self.image:getHeight())
  self.animation = anim8.newAnimation(g('1-4', 1), 0.2)

  --collider
  self.collider = self.world:newRectangleCollider(self.x, self.y, self.w, self.h)
  self.collider:setCollisionClass('Enemy')
  self.collider:setLinearDamping(4)
  self.collider:setObject(self)
  self.collider:setFixedRotation(true)
  self.collider.obj = self -- link collider with the object

  -- health and timer for display damage
  self.health = 3 -- prev 5
  self.is_hit = false

  local function check_hit()
    if self.is_hit then
      self.is_hit = false
    end
  end

  self.hit_timer = cron.every(0.5, check_hit) -- this timer is used for enemy blink when taking damage
end

-- update function
function Snake:update(dt)
  -- do update only if health is greater than zero
  if self.health > 0 then
    -- movement
    self.collider:applyForce(self.move_force * self.scale, 0)

    -- check collision with wall then flip movement
    if self.collider:enter('Wall') then
      self:flip()
    end

    -- update animation
    self.animation:update(dt)

    -- make sprite x & y cords same as collider
    self.x = self.collider:getX()
    self.y = self.collider:getY() - 8
  end

  -- hit timer update
  self.hit_timer:update(dt)
end

-- draw function
function Snake:draw()
  if self.health > 0 then
    if self.is_hit then -- if enemy is hit change enemy color
      love.graphics.setColor(1, 0, 0)
    end
    self.animation:draw(self.image, self.x, self.y, 0, self.scale, 1, 16, 16)
    love.graphics.setColor(1, 1, 1)
  end
end

-- flip the snake movement based on condition or time
function Snake:flip()
 if self.dir == "left" then
   self.dir = "right"
   self.scale = 1
 else
   self.dir = "left"
   self.scale = -1
 end
end

-- damage/hit function
function Snake:hit(dir)
  self.health = self.health - 1 -- subtract from health

  -- below condition push the snake on damage based on player dir
  if dir == "right" then
    self.collider:applyForce(self.move_force * 50, 0)
  else
    self.collider:applyForce(-self.move_force * 50, 0)
  end

  -- destroying
  if self.health <= 0 then
    self.collider:destroy() -- destroy the collider
  else
    self.is_hit = true
    self.hit_timer:reset() -- reset timer to 0
  end
end

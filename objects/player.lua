local anim8 = Anim8 -- animation library

Player = Actor:extend()

function Player:new(x, y, world)
  Player.super:new(x, y)
  self.w  = 16
  self.h  = 24
  self.dir = "right"
  self.scale_x = 1

  self.world = world -- world passed from game func 

 -- movement params 
  self.move_force = 400 -- player acceleration
  self.max_speed = 150

  -- jump parameters
  self.can_jump = false
  self.jump_force = -120
  self.jump_max = 250
  self.can_climb = false

  -- attack params
  self.is_attacking = false
  self.attack_duration = 0.6 -- attack anim duration
  self.attack_timer = 0 --counter for checking if attack duration has been crossed

  -- animations (player animation)
  self.image = love.graphics.newImage('assets/images/king.png')
  local g = anim8.newGrid(32, 32, self.image:getWidth(), self.image:getHeight())
  self.animations = {
    idle = anim8.newAnimation(g('1-3', 1), 0.2),
    walk = anim8.newAnimation(g('3-6', 1), 0.15),
    run  = anim8.newAnimation(g('17-20', 1), 0.2),
    jump = anim8.newAnimation(g('6-8', 1), 0.6),
    attack = anim8.newAnimation(g('13-15', 1), self.attack_duration/2),
}
  self.animation = self.animations.idle

  -- animation (attack animation)
  self.attack_image = love.graphics.newImage('assets/images/swoosh.png')
  local atck_g = anim8.newGrid(32, 32, self.attack_image:getWidth(), self.attack_image:getHeight())
  self.attack_animation = anim8.newAnimation(atck_g('1-5', 1), self.attack_duration/5)

  -- collider
  self.collider = self.world:newBSGRectangleCollider(self.x, self.y, self.w, self.h, 5)
  self.collider:setFriction(0.5) -- apply friction
  self.collider:setLinearDamping(2) -- reduce jump distance
  --self.collider:setDensity(2)
  self.collider:setLinearDamping(2)
  self.collider:setCollisionClass('Player') -- set collision class
  self.collider:setObject(self)
  self.collider:setFixedRotation(true) -- so that collider wont rotate

end

function Player:update(dt)
  -- movement controls
  -- only apply speed/force if player is not already moving at max speed
  local px, _ = self.collider:getLinearVelocity()
  if love.keyboard.isDown("left") and px > -self.max_speed then
    if self.can_jump then -- if jumping then reduce the force applied
      self.collider:applyForce(-self.move_force, 0)
    else
      self.collider:applyForce(-self.move_force/4, 0)
    end
    self.dir = "left"
  elseif love.keyboard.isDown("right") and px < self.max_speed then
    if self.can_jump then
      self.collider:applyForce(self.move_force, 0)
    else
      self.collider:applyForce(self.move_force/4, 0)
    end
    self.dir = "right"
  end

  -- one way platform
  self.collider:setPreSolve(function(collider_1, collider_2, contact)
    if collider_1.collision_class == 'Player' and collider_2.collision_class == 'Platform' then
      local px, py = collider_1:getPosition()
      local _, ph = self.w, self.h
      local _, ty = collider_2:getPosition()
      local _, th = collider_2.width, collider_2.height
      if py + ph/2 > ty - th/2 then
        contact:setEnabled(false)
        self.jump_force = -50 -- to fix double jump issue
      else
        self.jump_force = -120
      end
    end
  end)

  -- all animations function
  self:update_animations(dt, px)

  -- flip player sprite based on dir 
  if self.dir == "left" then
    self.scale_x = -1
  else
    self.scale_x =  1
  end

  -- jump controls
  if self.collider:enter('Ground') then
    self.can_jump = true
    self.jump_force = -120 -- to fix bug due to one way platforms
    self.can_climb = false
    self.collider:setGravityScale(1) -- revert back the gravity scale once player reaches ground
  elseif self.collider:enter('Platform') then
    self.can_climb = false
    self.can_jump=true
    self.collider:setGravityScale(1)
  elseif self.collider:enter('Box') then
    self.can_climb = false
    self.can_jump=true
    self.collider:setGravityScale(1)
end

  if love.keyboard.isDown("up") then
    if self.can_jump then
      self.collider:applyLinearImpulse(0, self.jump_force, self.x, self.y)
      self.can_jump = false
    end
  end

  -- apply collider position to player x & y cordinates
  self.x = self.collider:getX()
  self.y = self.collider:getY() - 4
end

-- keypress events
function Player:keypressed(key)
  -- attack trigger
  if key == "z" and not self.is_attacking then
    -- change attack variable and put both animations to frame 1
    self.is_attacking = true
    self.attack_animation:gotoFrame(1)
    self.animation:gotoFrame(1)
    self:attack()
   end
end

-- key released events
function Player:keyreleased(key)
  if key == "up" then
    self.collider:setGravityScale(2) -- to make player heavier (long press for more height) during jump by increasing gravity scale
  end
end

-- this function handles all the player animations
function Player:update_animations(dt, px)
  -- change animation state
  if self.can_jump and not self.is_attacking then -- means player is on ground and not attacking
   if px == 0 then
      self.animation = self.animations.idle
   elseif px < 0 then
      self.animation = self.animations.walk
    elseif px > 0 then
      self.animation = self.animations.walk
    end
  else
    -- player jump
    self.animation = self.animations.jump
  end

-- attacking animation
  if self.is_attacking then
    --self.animation:
    self.attack_timer = self.attack_timer + dt -- add attack_timer to delta time
    self.animation = self.animations.attack
    if self.attack_timer >= self.attack_duration then -- attack animation reached last frame
      self.is_attacking = false
      self.attack_timer = 0
    end
  end

  -- update all animation - anim8 library
  self.animation:update(dt)
  self.attack_animation:update(dt)

end

-- draw player sprite to screen
function Player:draw()
  self.animation:draw(self.image, self.x, self.y, 0, self.scale_x, 1, 16, 16)

  -- draw the attack sprite
  if self.is_attacking then
    local x_pos = 0
    if self.dir == "left" then
      x_pos = self.x - 8
    else
      x_pos = self.x + 8
    end
    self.attack_animation:draw(self.attack_image, x_pos, self.y, 0, self.scale_x, 1, 16, 16)
  end
end

function Player:attack()
  -- using query to check player-attack enemy collisions during attack 
  local x_pos = nil -- change collider position based on player dir
  if self.dir == "right" then
    x_pos = self.x + 16
  else
    x_pos = self.x - 16
  end
  local enemy_colliders = self.world:queryCircleArea(x_pos, self.y + 4, 12, {"Enemy"})
  for _, enemy_collider in ipairs(enemy_colliders) do
    local enemy = enemy_collider:getObject() -- get the collider parent object
    enemy:hit(self.dir)
  end
end

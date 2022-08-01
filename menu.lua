local menu = {}

function menu:load()
end

function menu:update(dt)
  if love.keyboard.isDown("x") then
    setScene("game")
  end
end

function menu:draw()
 love.graphics.print("menu screen", 64, 64)
end

return menu

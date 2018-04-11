require "termK"
require "mathK"

local function setwindowsize()
  love.window.setMode(terminal.width * 10, terminal.height * 10 + terminal.lineheight, {resizable=false})
end

function love.load()
  keys = {}
  
  fontsize = 24
  terminal = {}
  terminal.lineheight = fontsize * 2 + 2
  terminal.cursor = {}
  terminal.cursor.x = 20
  terminal.cursor.y = 20
  terminal.width = 100
  terminal.height = 50
  terminal.text = {}
  terminal.top = 20
  terminal.commands = ''
  terminal.inputhistory = {}
  font = love.graphics.newFont("fff-forward.regular.ttf", fontsize)
  font:setLineHeight( 1.5 )
  love.graphics.setFont(font)
  
  love.keyboard.setKeyRepeat(true)
  
  terminal.inputhistory[#terminal.inputhistory + 1] = ''
  
  setwindowsize()
  
  if love.filesystem.getRealDirectory(rootdir) == nil then
    love.filesystem.createDirectory(rootdir)
  end
end

function love.update(dt)
  
end

function love.keypressed(key, scancode, isrepeat)
  if key == 'backspace' then
    if mode ~= 'command' then
      terminal.inputhistory[#terminal.inputhistory] = terminal.inputhistory[#terminal.inputhistory]:sub(1, -2)
      inputBuff = terminal.inputhistory[#terminal.inputhistory]
    else
      terminal.commands = terminal.commands:sub(1,-2)
    end
  elseif key == 'return' then
    termK.input('\n')
  elseif key == 'up' then
    terminal.inputhistory[#terminal.inputhistory] = terminal.inputhistory[mathK.clamp(#terminal.inputhistory - 1, 1, #terminal.inputhistory)]:sub(1,-2)
    inputBuff = terminal.inputhistory[#terminal.inputhistory]
  elseif key == 'escape' then
    termK.save()
    
    inputBuff = ''
    terminal.inputhistory[#terminal.inputhistory + 1] = ''
  elseif key == 'lctrl' then
    local tempstuff = mode
    mode = tempmode
    tempmode = tempstuff
  else
    keys[key] = true
  end
end

function love.keyreleased( key, scancode )
  keys[key] = false
end

function love.textinput(t)
    termK.input(t)
end

function love.draw()
  if terminal.cursor.y + 66 > terminal.height * 10 then
    terminal.top = terminal.top - (terminal.cursor.y + 66 - terminal.height * 10)
    terminal.cursor.y = terminal.height * 10 - 66
  end
  
  local drawx = 20
  local drawy = terminal.top
  
  if #terminal.text > 0 then
    for i = 1, #terminal.text do
      love.graphics.printf( terminal.text[i], drawx, drawy, terminal.width * 10 - 40)
      local foo, wrappedtext = font:getWrap( terminal.text[i], terminal.width * 10 - 40 )
      
      drawy = drawy + mathK.clamp(#wrappedtext, 1, #wrappedtext + 2) * terminal.lineheight
    end
  end
  
  if mode ~= 'edit' then
    love.graphics.printf( 'K:' .. curdir .. '>' .. terminal.inputhistory[#terminal.inputhistory], terminal.cursor.x, terminal.cursor.y, terminal.width * 10 - 40)
  else
    love.graphics.printf( terminal.inputhistory[#terminal.inputhistory], terminal.cursor.x, terminal.cursor.y, terminal.width * 10 - 40)
  end

  love.graphics.printf( terminal.commands, 20, terminal.height * 10, terminal.width * 10 - 40)
end
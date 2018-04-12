termK = {}
errorcodes = {'ERROR CODE:1 (TRIED TO USE AN EMPTY VALUE)'}

rootdir = 'ConsoleRoot'
curdir = '/'

editingfile = ''

tempvars = {}
writingto = ''

inputBuff = ''
secondinputBuff = ''

mode = 'terminal'
oldmode = ''

program = nil
running = false

enteringcommand = false

function termK.start (command)
  inputBuff = ''
  local chunks = {}
  for i in string.gmatch(command, "%S+") do
    chunks[#chunks + 1] = i
  end
  
  if #chunks > 0 then
    return termK.evalcom(chunks[1], mathK.subrange(chunks, 2, #chunks))
  end
end

function termK.evalcom (command, args)
  local out = ''
  
  if commands[command] ~= nil then
    return commands[command](args)
  end

  return DEFAULT_HANDLE(command, args)
end

function termK.save()
  if mode == 'edit' then
    love.filesystem.write( rootdir .. '/' .. curdir .. '/' .. editingfile, inputBuff )
  end
end

function termK.toterminal()
  editingfile = ''
  mode = 'terminal'
end

function termK.input (t)
  if not enteringcommand then
    terminal.inputhistory[#terminal.inputhistory] = terminal.inputhistory[#terminal.inputhistory] .. t
  else
    terminal.commands = terminal.commands .. t
  end
  
  if t == '\n' then
    if enteringcommand then
      if terminal.commands:sub(1,-2) == 'q' then
        termK.toterminal()
        
        inputBuff = ''
        terminal.inputhistory[#terminal.inputhistory + 1] = ''
      elseif terminal.commands:sub(1,-2) == 's' then
        termK.save()
      elseif terminal.commands:sub(1,-2) == 'e' then
        running = true

        terminal.commands = ''
        enteringcommand = false

        program = coroutine.create(function ()
          secondinputBuff = terminal.inputhistory[#terminal.inputhistory]
          terminal.inputhistory[#terminal.inputhistory] = ''
          inputBuff = ''
          termK.start('CLS')
  
          executablelines, _ = love.filesystem.read( rootdir .. '/' .. curdir .. '/' .. editingfile )
          for line in executablelines:gmatch("([^\n]*)\n?") do
            termK.start(line)
          end
  
          termK.output('PRESS ESCAPE TO CONTINUE')
        end)
        coroutine.resume(program)
      end

      terminal.commands = ''
      enteringcommand = false
    elseif mode == 'terminal' and not enteringcommand then
      termK.output('K:' .. curdir .. '>' .. inputBuff)
      terminal.inputhistory[#terminal.inputhistory + 1] = ''
      termK.start(inputBuff)
    elseif mode == 'input' then
      termK.output('>' .. inputBuff)
      tempvars[writingto] = inputBuff
      mode = oldmode
      inputBuff = ''
      terminal.inputhistory[#terminal.inputhistory + 1] = ''

      if program ~= nil then
        coroutine.resume(program)
      end
    end
  else
    inputBuff = terminal.inputhistory[#terminal.inputhistory]
  end
end

function termK.output (text)
  local foo, wrappedtext = font:getWrap( text, terminal.width * 10 - 40 )
  
  if terminal.text[#terminal.text + 1] == nil then
    terminal.text[#terminal.text + 1] = text
  else
    terminal.text[#terminal.text + 1] = terminal.text[#terminal.text + 1] .. text
  end
  terminal.cursor.y = terminal.cursor.y + mathK.clamp(#wrappedtext, 1, #wrappedtext) * terminal.lineheight
end
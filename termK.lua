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

enteringcommand = false

function termK.start (command)
  --print (command)
  
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
  
  -- PRINT COMMAND
  if command == 'PRINT' then
    out = termK.start(mathK.tabletostring(args))
    
    if ((out:sub(1, 1) == "'" and out:sub(-1, -1) == "'") or (out:sub(1, 1) == '"' and out:sub(-1, -1) == '"')) then
      out = out:sub(2, -2)
    end
    
    if out == nil then
      termK.output(errorcodes[1])
      return errorcodes[1]
    else
      termK.output(out)
      return out
    end
  elseif command == 'CLS' then
    tempvars = {}
    if #terminal.text > 0 then
      for i = 1, #terminal.text do
        terminal.text[i] = nil
        terminal.cursor.x = 20
        terminal.cursor.y = 20
        terminal.top = 20
      end
      return "'" .. 'true' .. "'"
    end
    return "'" .. 'false' .. "'"
  elseif command == 'SET' then
    for i = 2, #args do
      out = out .. args[i] .. ' '
    end
    
    out = out:sub(1, -2)
    
    tempvars[args[1]] = termK.start(out)
    
    return "'" .. out .. "'"
  elseif command == 'HELP' then
    termK.output('COMMANDS ARE -- CLS   HELP   PRINT   SET')
    return true
  elseif command == 'LS' then
    local out = ''
    for i,fname in ipairs(love.filesystem.getDirectoryItems( rootdir .. '/' .. curdir )) do
      info = love.filesystem.getInfo( rootdir .. '/' .. curdir .. '/' .. fname )
      if info.type == 'directory' then
        out = out .. fname .. '/   '
      else
        out = out .. fname .. '   '
      end
    end
    termK.output(out:sub(1,-4))
  elseif command == 'MKDIR' then
    love.filesystem.createDirectory( rootdir .. '/' .. curdir .. '/' .. mathK.tabletostring(args) )
  elseif command == 'MV' then
    local realdir = love.filesystem.getRealDirectory('')
    if args[2] == nil then
      love.filesystem.remove( rootdir .. '/' .. curdir .. args[1] )
    else
      os.rename(realdir .. '/' .. rootdir .. '/' .. curdir .. args[1], realdir .. '/' .. rootdir .. '/' .. curdir .. args[2])
    end
  elseif command == 'CD' then
    if mathK.tabletostring(args) ~= '..' then
      info = love.filesystem.getInfo( rootdir .. '/' .. curdir .. mathK.tabletostring(args) )
    
      if info ~= nil then
        if info.type == 'directory' then
          curdir = curdir .. mathK.tabletostring(args) .. '/'
        end
      end
    else
      if curdir:sub(1,-2) ~= '/' then
        curdir = curdir:sub(1,-2):sub(1, curdir:sub(1,-2):match'^.*()/')
      end
    end
  elseif command == 'EDIT' then
    info = love.filesystem.getInfo( rootdir .. '/' .. curdir .. '/' .. mathK.tabletostring(args) )
    if info == nil then
      love.filesystem.write( rootdir .. '/' .. curdir .. '/' .. mathK.tabletostring(args), '' )
      info = love.filesystem.getInfo( rootdir .. '/' .. curdir .. '/' .. mathK.tabletostring(args) )
    end
    
    if info.type == 'file' then
      inputBuff, _ = love.filesystem.read( rootdir .. '/' .. curdir .. '/' .. mathK.tabletostring(args) )
      terminal.inputhistory[#terminal.inputhistory] = inputBuff
      
      termK.start('CLS')
      
      editingfile = mathK.tabletostring(args)
      
      mode = 'edit'
    end
  else
    local out = tempvars[mathK.tabletostring(mathK.tconcat({command}, args))]
    
    if out == nil then
      if args == nil then
        if command == nil then
          return errorcodes[1]
        end
        return command
      end
      return mathK.tabletostring(mathK.tconcat({command}, args))
    else
      --termK.output(out)
      return out
    end
  end
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
    if mode == 'terminal' then
      termK.output('K:' .. curdir .. '>' .. inputBuff)
      terminal.inputhistory[#terminal.inputhistory + 1] = ''
      termK.start(inputBuff)
    elseif enteringcommand then
      if terminal.commands:sub(1,-2) == 'q' then
        termK.toterminal()
        
        inputBuff = ''
        terminal.inputhistory[#terminal.inputhistory + 1] = ''
      elseif terminal.commands:sub(1,-2) == 's' then
        termK.save()
      elseif terminal.commands:sub(1,-2) == 'e' then
        mode = 'running'
        termK.start('CLS')
        for line in terminal.inputhistory[#terminal.inputhistory]:gmatch("([^\n]*)\n?") do
          termK.start(line)
        end
        termK.output('PRESS ESCAPE TO CONTINUE')
      end

      terminal.commands = ''
      enteringcommand = false
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
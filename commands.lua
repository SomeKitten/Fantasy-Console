commands = {}

commands['PRINT'] = function(args)
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
end

commands['CLS'] = function(args)
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
end

commands['SET'] = function(args)
    local out = ''
    for i = 2, #args do
        out = out .. args[i] .. ' '
      end
      
      out = out:sub(1, -2)
      
      tempvars[args[1]] = termK.start(out)
      
      return "'" .. out .. "'"
end

commands['HELP'] = function(args)
    termK.output('COMMANDS ARE -- HELP,   CLS,   PRINT <variable or value>,   SET <variable> <value>,   LS,   MKDIR <directory name>,   MV <starting file> [ending file (leave empty for delete)],   CD <directory>,   EDIT <file>,   INPUT <variable>,   RUN <file>')
    return true
end

commands['LS'] = function(args)
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
end

commands['MKDIR'] = function(args)
    love.filesystem.createDirectory( rootdir .. '/' .. curdir .. '/' .. mathK.tabletostring(args) )
end

commands['MV'] = function(args)
    local realdir = love.filesystem.getRealDirectory('')
    if args[2] == nil then
      love.filesystem.remove( rootdir .. '/' .. curdir .. args[1] )
    else
      os.rename(realdir .. '/' .. rootdir .. '/' .. curdir .. args[1], realdir .. '/' .. rootdir .. '/' .. curdir .. args[2])
    end
end

commands['CD'] = function(args)
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
end

commands['EDIT'] = function(args)
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

    running = false

    local oldprogram = program
    program = nil
    coroutine.yield(oldprogram)
end

commands['INPUT'] = function(args)
    oldmode = mode
    mode = 'input'
    writingto = mathK.tabletostring(args)
    coroutine.yield(program)
end

commands['RUN'] = function(args)
    info = love.filesystem.getInfo( rootdir .. '/' .. curdir .. '/' .. mathK.tabletostring(args) )
    if info == nil then
        return errorcodes[1]
    end

    prerunmode = mode

    running = true

    terminal.commands = ''
    enteringcommand = false

    program = coroutine.create(function ()
        secondinputBuff = terminal.inputhistory[#terminal.inputhistory]
        terminal.inputhistory[#terminal.inputhistory] = ''
        inputBuff = ''
        termK.start('CLS')

        local executablelines, _ = love.filesystem.read( rootdir .. '/' .. curdir .. '/' .. mathK.tabletostring(args) )
        for line in executablelines:gmatch("([^\n]*)\n?") do
            termK.start(line)
        end

        termK.output('PRESS ESCAPE TO CONTINUE')
    end)
    coroutine.resume(program)
end

DEFAULT_HANDLE = function(command, args)
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
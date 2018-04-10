mathK = {}

function mathK.clamp(n, min, max)
    if n < min then return min end
    if n > max then return max end
    return n
end

function mathK.wrap(n, min, max)
    if n < min then return mathK.wrap(max + n, min, max) end
    if n > max then return mathK.wrap(n - (max - min), min, max) end
    return n
end

function mathK.subrange(t, first, last)
    local out = {}
    
    for i = first, last do
      out[i - first + 1] = t[i]
    end
    
    return out
end

function mathK.tconcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function mathK.tabletostring(args)
  out = ''
  for i = 1, #args do
    out = out .. args[i] .. ' '
  end
  
  return out:sub(1, -2)
end

function tablehas (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end
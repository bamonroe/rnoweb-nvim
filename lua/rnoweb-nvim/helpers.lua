local M = {}

M.split = function(pString, pPattern)
   local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = pString:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
     table.insert(Table,cap)
      end
      last_end = e+1
      s, e, cap = pString:find(fpat, last_end)
   end
   if last_end <= #pString then
      cap = pString:sub(last_end)
      table.insert(Table, cap)
   end
   return Table
end


local add_front = function(s, n)
  for _=1,n do
    s = " " .. s
  end
  return s
end

local add_back = function(s, n)
  for _=1,n do
    s = s .." "
  end
  return s
end

M.center_pad = function(s, a)
  local famt = a % 2 == 0 and a / 2 or math.floor(a / 2)
  local bamt = a % 2 == 0 and a / 2 or math.ceil(a / 2)
  s = add_front(s, famt)
  s = add_back(s, bamt)
  return s
end
--
-- Function to get length of string in charachter count, not byte count
M.slen = function(s)
  local _, count = string.gsub(s, "[^\128-\193]", "")
  return count
end

M.isin = function(v, t)
  local res = false
  for key, val in pairs(t) do
    if not res then
      res = v == val
    end
  end
  return res
end

return M

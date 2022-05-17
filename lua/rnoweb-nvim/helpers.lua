local info = require'rnoweb-nvim.info'

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
  local famt = math.floor(a / 2)
  local bamt = math.ceil(a / 2)
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

-- Check if a file exists
M.file_exists = function(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- Read lines from file into a table
M.read_lines = function(file)
  if not M.file_exists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end

M.write_lines = function(file, lines)
  -- Get rid of the words file if it exists
  if M.file_exists(file) then
    os.remove(file)
  end

  local fp = io.open(file, "a")
  for k,_ in pairs(lines) do
    fp:write(k, "\n")
  end
  fp:close()

end

M.gtext = function(node)
  local l0, c0, l1, c1 = node:range()
  local lines = vim.api.nvim_buf_get_lines(info.bufnr, l0, l1 + 1, false)
  local out = lines[1]
  out = string.sub(out, c0 + 1, c1)
  return(out)
end

return M

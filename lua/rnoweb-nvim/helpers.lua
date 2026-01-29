local ts   = vim.treesitter
local info = require'rnoweb-nvim.info'

-- Cache frequently used functions
local nvim_buf_set_extmark = vim.api.nvim_buf_set_extmark

local M = {}

-- A debugging function that writes to a file
M.db = function (line)
  line = vim.inspect(line)
  local file = "/tmp/dbug"
  local fp = io.open(file, "a")
  fp:write(line, "\n")
  fp:flush()
  fp:close()
end

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
  if s == nil then return(0) end
  local _, count = string.gsub(s, "[^\128-\193]", "")
  return count
end

M.tlen = function(t)
  local n = 0
  for _, _ in pairs(t) do
    n = n + 1
  end
  return n
end

M.ncols = function(lnum)
  local line = vim.api.nvim_buf_get_lines(info.bufnr, lnum, lnum + 1, true)[1]
  local tabstop = vim.api.nvim_get_option("tabstop")
  line = line:gsub("\t", string.rep(" ", tabstop))
  return M.slen(line)
end

M.gmatch = function(s)
  local out = {}
  if s == nil then return out end
  for c in s:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
    out[#out+1] = c
  end
  return out
end

M.isin = function(v, t)
  for _, val in ipairs(t) do
    if v == val then return true end
  end
  return false
end

-- Check if a file exists
M.file_exists = function(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- Read lines from file into a table
M.read_lines = function(file)
  local f = io.open(file, "r")
  if not f then return {} end
  local lines = {}
  for line in f:lines() do
    lines[#lines + 1] = line
  end
  f:close()
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
  return ts.get_node_text(node, info.bufnr)
end

M.mc_conceal = function(bufnr, ns, beg_line, beg_col, opts, node_len)
  local conceal_text = opts.conceal
  if conceal_text == nil then return end

  local end_line = opts.end_line or beg_line
  local hl_group = opts.hl_group or "Conceal"

  if type(conceal_text) ~= "string" then
    conceal_text = tostring(conceal_text)
  end

  local conceal_len = M.slen(conceal_text)
  local padding = node_len - conceal_len
  local ids = info.ids

  -- Get the actual line length to avoid end_col out of range errors
  local line = vim.api.nvim_buf_get_lines(bufnr, beg_line, beg_line + 1, false)[1]
  local line_len = line and #line or 0

  -- Calculate the max end column (node end position)
  local max_end_col = math.min(beg_col + node_len, line_len)

  -- First, conceal the padding (extra chars that need to be hidden)
  if padding > 0 then
    local nopts = {
      end_line       = end_line,
      end_col        = math.min(beg_col + padding, max_end_col),
      virt_text      = {{'', hl_group}},
      virt_text_pos  = "overlay",
      virt_text_hide = true,
      conceal        = '',
    }
    ids[#ids + 1] = nvim_buf_set_extmark(bufnr, ns, beg_line, beg_col, nopts)
  end

  -- Then create one extmark per conceal character
  local col = beg_col + math.max(padding, 0)
  for char in conceal_text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
    -- Stop if we've exceeded the node bounds
    if col >= max_end_col then break end
    local nopts = {
      end_line       = end_line,
      end_col        = math.min(col + 1, max_end_col),
      virt_text      = {{'', hl_group}},
      virt_text_pos  = "overlay",
      virt_text_hide = true,
      hl_group       = hl_group,
      conceal        = char,
    }
    ids[#ids + 1] = nvim_buf_set_extmark(bufnr, ns, beg_line, col, nopts)
    col = col + 1
  end
end

M.in_tablev= function(v, t)
  for _,i in pairs(t) do
    if i == v then
      return(true)
    end
  end
  return false
end

M.in_tablek= function(v, t)
  for k,_ in pairs(t) do
    if k == v then
      return(true)
    end
  end
  return false
end

return M

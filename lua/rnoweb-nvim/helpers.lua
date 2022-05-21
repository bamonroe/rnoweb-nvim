local ts   = vim.treesitter
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

M.gmatch = function(s)
  local out = {}
  for c in s:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
    out[#out+1] = c
  end
  return out
end

M.isin = function(v, t)
  local res = false
  for _, val in pairs(t) do
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
  return ts.get_node_text(node, info.bufnr)
end

M.mc_conceal = function(bufnr, ns, beg_line, beg_col, opts, node_len)

  local conceal_text = opts["conceal"]
  local conceal_len  = M.slen(conceal_text)

  local padding = node_len - conceal_len

  -- Firstly, conceal the padding
  local nopts = {
    end_line = opts["end_line"],
    end_col  = beg_col + padding,
    virt_text = {{'', "Conceal"}},
    virt_text_pos = "overlay",
    virt_text_hide = true,
    conceal = '',
  }
  info.ids[#info.ids+1] = vim.api.nvim_buf_set_extmark(
    bufnr,
    ns,
    beg_line,
    beg_col,
    nopts)

  local ct_utf8 = M.gmatch(conceal_text)

  for i = 1,conceal_len do
    local cchar = ct_utf8[i]
    nopts = {
      end_line = opts["end_line"],
      end_col  = beg_col + padding + i,
      virt_text = {{'', "Conceal"}},
      virt_text_pos = "overlay",
      virt_text_hide = true,
      hl_group = opts["hl_group"],
      conceal = cchar,
    }
    info.ids[#info.ids+1] = vim.api.nvim_buf_set_extmark(
      bufnr,
      ns,
      beg_line,
      beg_col + padding + i - 1,
      nopts)
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

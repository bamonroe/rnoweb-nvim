local M = {}

local sym = require'rnoweb-nvim.symbols'

local function i(...)
  print(vim.inspect(...))
end

local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

local function lines_from(file)
  if not file_exists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end
--
-- Function to get length of string in charachter count, not byte count
local slen = function(s)
  local _, count = string.gsub(s, "[^\128-\193]", "")
  return count
end

local function gtext(node)
  local l0, c0, l1, c1 = node:range()

  local lines = vim.api.nvim_buf_get_lines(M.info.bufnr, l0, l1 + 1, false)
  local out = lines[1]
  out = string.sub(out, c0 + 1, c1)
  return(out)
end

local function add_front(s, n)
  for _=1,n do
    s = " " .. s
  end
  return s
end

local function add_back(s, n)
  for _=1,n do
    s = s .." "
  end
  return s
end

local function center_pad(s, a)
  local famt = a % 2 == 0 and a / 2 or math.floor(a / 2)
  local bamt = a % 2 == 0 and a / 2 or math.ceil(a / 2)
  s = add_front(s, famt)
  s = add_back(s, bamt)
  return s
end

M.dcount = 0
local dbug =  function()
  M.dcount = M.dcount + 1
  print("@@here" .. M.dcount)
end

M.info = {
  ns    = vim.api.nvim_create_namespace("rnoweb_inline"),
  bufnr = vim.api.nvim_get_current_buf(),
  ids = {}
}

M.del_inline = function()
  local v = vim.api
  for _, val in pairs(M.info.ids) do
    v.nvim_buf_del_extmark(M.info.bufnr, M.info.ns, val)
  end
end

M.mask_inline = function()

  -- Shortcuts
  local v  = vim.api
  local nt = vim.treesitter.query.get_node_text
  local q  = vim.treesitter.query

  -- Clear the current marks
  M.del_inline()

  --local u = require('nvim-treesitter.ts_utils')
  local parser = vim.treesitter.get_parser(M.info.bufnr)
  local tree   = parser:parse()
  local root   = tree[1]:root()

  local inline = q.parse_query("rnoweb", "(rinline (renv_content) @inline_content)")

  local count = 0

  for _, match, _ in inline:iter_matches(root, M.info.bufnr) do
    for _, node in pairs(match) do
      count = count + 1

      -- Get the rane of this node
      local l0, c0, _, c1 = node:range()

      -- Get the text that will be in this ndoe
      local fname = "./inline/" .. count .. ".txt"
      local text = lines_from(fname)[1]

      if text then

        -- Length of the space available (assuming on the same line)
        local clen  = c1 - c0
        local ntext = nt(node, M.info.bufnr)

        text = text and text or ntext
        text = string.sub(text, 1, clen)
        local pad_amt = clen - slen(text)
        text = center_pad(text, pad_amt)

        local opts = {
          end_col = c1,
          virt_text = {{text, "Conceal"}},
          virt_text_pos = "overlay",
          virt_text_hide = true,
        }
        M.info.ids[count] = v.nvim_buf_set_extmark(M.info.bufnr, M.info.ns, l0, c0, opts)

      end

    end
  end
end

local function conceal_symbol(node, cmd)
  local l0, c0, l1, c1 = node:range()
  local clen  = c1 - c0

  local text = sym.get(cmd)
  text = string.sub(text, 1, clen)
  local pad_amt = clen - slen(text)

  text = center_pad(text, pad_amt)

  local opts = {
    end_col = c1,
    virt_text = {{text, "Conceal"}},
    virt_text_pos = "overlay",
    virt_text_hide = true,
  }
  M.info.ids[#M.info.ids+1] = vim.api.nvim_buf_set_extmark(M.info.bufnr, M.info.ns, l0, c0, opts)
end

M.mask_texsym = function()
  --
  -- Shortcuts
  local q  = vim.treesitter.query

  local ntp    = require'nvim-treesitter.parsers'
  local parser = ntp.get_parser(0)

  local author = q.parse_query("latex", "(generic_command (command_name) @cmd)")

  parser:for_each_tree(function(_, tree)
    local ttree = tree:parse()
    local root  = ttree[1]:root()

    for _, node, _ in author:iter_captures(root, M.info.bufnr) do
      local cmd = gtext(node)
      if sym.map[cmd] then
        conceal_symbol(node, cmd)
      end
    end


  end)

end

return M

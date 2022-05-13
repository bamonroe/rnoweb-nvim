local M = {}

local sym = require'rnoweb-nvim.symbols'
local h   = require'rnoweb-nvim.helpers'
local q  = vim.treesitter.query

local function gtext(node)
  local l0, c0, l1, c1 = node:range()
  local lines = vim.api.nvim_buf_get_lines(M.info.bufnr, l0, l1 + 1, false)
  local out = lines[1]
  out = string.sub(out, c0 + 1, c1)
  return(out)
end

M.info = {
  ns    = vim.api.nvim_create_namespace("rnoweb-nvim"),
  bufnr = vim.api.nvim_get_current_buf(),
  ids = {}
}

M.del_marks = function()
  local v = vim.api
  for _, val in pairs(M.info.ids) do
    v.nvim_buf_del_extmark(M.info.bufnr, M.info.ns, val)
  end
end

M.mask_inline = function()
  -- Clear the current marks
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
      local text = h.read_lines(fname)[1]

      if text then

        -- Length of the space available (assuming on the same line)
        local clen  = c1 - c0
        local ntext = gtext(node)

        text = text and text or ntext
        text = string.sub(text, 1, clen)
        local pad_amt = clen - h.slen(text)
        text = h.center_pad(text, pad_amt)

        local opts = {
          end_col = c1,
          virt_text = {{text, "Conceal"}},
          virt_text_pos = "overlay",
          virt_text_hide = true,
        }
        M.info.ids[count] = vim.api.nvim_buf_set_extmark(M.info.bufnr, M.info.ns, l0, c0, opts)

      end

    end
  end
end

local function conceal_symbol(node, cmd)

  local l0, c0, _, c1 = node:range()
  local clen  = c1 - c0

  local text = sym.get(cmd)
  text = string.sub(text, 1, clen)
  local pad_amt = clen - h.slen(text)

  text = h.center_pad(text, pad_amt)

  local opts = {
    end_col = c1,
    virt_text = {{text, "Conceal"}},
    virt_text_pos = "overlay",
    virt_text_hide = true,
  }
  M.info.ids[#M.info.ids+1] = vim.api.nvim_buf_set_extmark(M.info.bufnr, M.info.ns, l0, c0, opts)
end

M.mask_texsym = function()

  local parser = vim.treesitter.get_parser(M.info.bufnr)
  local cmd_q = q.parse_query("latex", "(generic_command (command_name) @cmd)")

  parser:for_each_tree(function(_, tree)
    local ttree = tree:parse()
    local root  = ttree[1]:root()
    for _, node, _ in cmd_q:iter_captures(root, M.info.bufnr) do
      local cmd = gtext(node)
      if sym.map[cmd] then
        conceal_symbol(node, cmd)
      end
    end
  end)

end

M.make_spell = function()
  -- Shortcuts
  local parser = vim.treesitter.get_parser(M.info.bufnr)
  local author = q.parse_query("latex", "(generic_command (command_name) @cmd)")

  local cmds = {}

  -- Save all the command names in a table
  parser:for_each_tree(function(_, tree)
    local ttree = tree:parse()
    local root  = ttree[1]:root()
    for _, node, _ in author:iter_captures(root, M.info.bufnr) do
      local txt = gtext(node)
      txt = string.sub(txt, 2)
      cmds[txt] = 1
    end
  end)

  -- The words file
  local fname = "/home/bam/.config/nvim/spell/latex"
  local lwords = fname .. ".words"
  local spellfile = fname .. ".utf-8.spl"

  -- Write the command names to a words spell-file
  h.write_lines(lwords, cmds)

  -- Make a spell file from the words
  local mks = "silent mkspell! "
  mks = mks .. spellfile .. " "
  mks = mks .. lwords
  vim.cmd(mks)

  -- Get the current spell languages
  local splang = h.split(vim.o.spelllang, ",")

  -- If latex isn't in the list, add it as an option
  if not h.isin("latex", splang) then
    splang[#splang+1] = "latex"
    local s = ""
    for _, l in pairs(splang) do
      s = s .. l .. ","
    end
    local val = "silent set spelllang=" .. s
    vim.cmd(val)
  end

end

return M

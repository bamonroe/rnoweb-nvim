local info = require'rnoweb-nvim.info'
local sym  = require'rnoweb-nvim.symbols'
local nh   = require'rnoweb-nvim.node_hooks'
local h    = require'rnoweb-nvim.helpers'
local q    = vim.treesitter.query

local M = {}
M.opts = {
  filetypes = {"*.Rnw", "*.tex"},
  tex2latex = true,
  set_conceal = true,
  setup = false,
}
M.auid = vim.api.nvim_create_augroup("rnoweb-nvim-pkg", {
  clear = true,
})

M.tex2latex = function()
  if vim.bo.filetype == "tex" then
    vim.pretty_print("changing to latex")
    vim.bo.filetype = "latex"
  end
end

-- Initial setup function
M.setup = function(opts)
  opts = opts and opts or M.opts
  for k,v in pairs(opts) do
    M.opts[k] = v
  end
  M.opts.setup = true

  if M.opts.set_conceal then
    vim.o.conceallevel = 2
  end

  -- Optionally force tex files to be recocnized as latex
  if M.opts.tex2latex then
    -- Change tex to latex
    vim.api.nvim_create_autocmd({"FileType"}, {
      group = M.auid,
      pattern = {"*.tex"},
      callback = M.tex2latex
    })
  end
end

-- This function deletes the extmarks that have been created by this plugin
-- This is how marks are "refreshed"
M.del_marks = function()
  local v = vim.api
  for _, val in pairs(info.ids) do
    v.nvim_buf_del_extmark(info.bufnr, info.ns, val)
  end
  -- We've deleted the marks, now clear the saved id numbers
  info.ids = {}
  info["beg_env"] = nil
end

-- This function replaces inline R code with the results of that code
-- not useful for stand-alone LaTeX
M.mask_inline = function()

  -- Inline R code will only work with rnoweb queries
  if info.ft ~= "rnoweb" then
    return {}
  end

  -- Get the parser for this buffer
  local parser = vim.treesitter.get_parser(info.bufnr)
  local tree   = parser:parse()
  local root   = tree[1]:root()

  local inline = q.parse_query("rnoweb", "(rinline (renv_content) @inline_content)")

  local count = 0
  for _, match, _ in inline:iter_matches(root, info.bufnr) do
    for _, node in pairs(match) do
      -- Need to count matches to correctly get the code results
      count = count + 1
      -- Get the rane of this node
      local l0, c0, _, c1 = node:range()
      -- Get the text that will be in this ndoe
      local fname = "./inline/" .. count .. ".txt"
      local text = h.read_lines(fname)[1]
      -- Length of the space available (assuming on the same line)
      local clen  = c1 - c0
      local ntext = h.gtext(node)

      text = text and text or ntext
      text = string.sub(text, 1, clen)

      local opts = {
        end_col = c1,
        virt_text_pos = "overlay",
        virt_text_hide = true,
        conceal = text
      }

      -- Multi-character conceal
      h.mc_conceal(
        info.bufnr,
        info.ns,
        l0,
        c0,
        opts,
        clen
      )

    end
  end
end

-- This is the meaty function that does the latex concealing
-- Works for rnoweb and latex filetypes
M.mask_texsym = function()
  local parser = vim.treesitter.get_parser(info.bufnr)
  parser:for_each_tree(function(_, tree)
    local ttree = tree:parse()
    local root  = ttree[1]:root()
    for _, d in sym.get_queries(root, info.bufnr) do
      local lang  = d["lang"]
      local query = d["query"]
      local cmd   = d["cmd"]
      for _, node, _ in query do
        nh[cmd](lang, node)
      end
    end
  end)

end

-- Unfortunatly, basically all latex commands show as badly spelled. this
-- function writes the latex command names to a file, generates a spell file,
-- and appends to the spell-lang. This helps with a huge amount of spelling
-- misses.
-- I'm hoping to obsolete this function by the recently merged spellsitter functionality
M.make_spell = function()
  -- Shortcuts
  local parser = vim.treesitter.get_parser(info.bufnr)
  local author = q.parse_query("latex", "(generic_command (command_name) @cmd)")

  local cmds = {}

  -- Save all the command names in a table
  parser:for_each_tree(function(_, tree)
    local ttree = tree:parse()
    local root  = ttree[1]:root()
    for _, node, _ in author:iter_captures(root, info.bufnr) do
      local txt = h.gtext(node)
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

-- This is the main function to call
M.refresh = function()
    info.set_info()
    M.del_marks()
    M.mask_texsym()
    M.mask_inline()
    M.make_spell()
end

return M

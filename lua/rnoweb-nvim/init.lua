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
    vim.print("changing to latex")
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
  info.reset()
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

  local inline = q.parse("rnoweb", "(rinline (renv_content) @inline_content)")

  local count = 0
  for _, match, _ in inline:iter_matches(root, info.bufnr) do
    for _, node in pairs(match) do
      -- Need to count matches to correctly get the code results
      count = count + 1
      -- Get the rane of this node
      node = node[1]
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

    local ttree1
    for i,j in pairs(ttree) do
      ttree1 = j
      break
    end
    local root  = ttree1:root()

    for _, d in sym.get_queries(root, info.bufnr) do
      local lang   = d["lang"]
      local imatch = d["match"]
      local cmd    = d["cmd"]

      for _, match, meta in imatch do
        -- We want to know if there's multiple matches to correctly parse the
        -- metadata per match
        local nmatches = h.tlen(match)
        for id, node in pairs(match) do
          node = node[1]
          -- Get the per-match metadata
          local mmeta = meta and meta or {}
          if nmatches > 0 then
            mmeta = meta[id] and meta[id] or {}
          end
          -- Ignore nodes marked with the "ignore" metadata
          if mmeta["ignore"] == nil or mmeta["ignore"] == "false" then
            nh[cmd](lang, node, mmeta)
          end
        end
      end
    end
  end)

end

-- This is the main function to call
M.refresh = function()
    info.set_info()
    M.del_marks()
    M.mask_texsym()
    M.mask_inline()
end

M.compile_rnw = function()
  local rnw_path = vim.api.nvim_buf_get_name(0)

  if not rnw_path:match("%.Rnw$") then
    print("Current buffer is not an .Rnw file.")
    return
  end

  -- Compute the corresponding .tex output path
  local tex_path = rnw_path:gsub("%.Rnw$", ".tex")

  -- Escape backslashes on Windows if needed
  local esc_rnw = rnw_path:gsub("\\", "\\\\")
  local esc_tex = tex_path:gsub("\\", "\\\\")

  -- Step 1: Knit to tex
  local knit_cmd = string.format([[R -e 'knitr::knit("%s", output = "%s")']], esc_rnw, esc_tex)

  -- Step 2: Compile to PDF using latexmk
  local latex_cmd = string.format("latexmk -f -pdf %s", vim.fn.shellescape(tex_path))

  -- Combine both commands using a shell
  local full_cmd = string.format("%s && %s", knit_cmd, latex_cmd)

  -- Run in terminal split
  vim.cmd("botright split | terminal " .. full_cmd)
end

-- Create a user command for easy invocation
vim.api.nvim_create_user_command("CompileRnw", M.compile_rnw, {})

--[[
M.test = function()
  vim.print('in test')
  local parser = vim.treesitter.get_parser(info.bufnr, "latex")
  local tree   = parser:parse()
  local root   = tree[1]:root()
  sym.get_inline_text_macros(root, info.bufnr)

end
--]]

return M

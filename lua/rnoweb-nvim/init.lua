local info = require'rnoweb-nvim.info'
local sym  = require'rnoweb-nvim.symbols'
local nh   = require'rnoweb-nvim.node_hooks'
local h    = require'rnoweb-nvim.helpers'
local q    = vim.treesitter.query

local M = {}
M.opts = {
  tex2latex = true,
  set_conceal = true,
  setup = false,
}
M.auid = vim.api.nvim_create_augroup("rnoweb-nvim-pkg", {
  clear = true,
})

M.tex2latex = function()
  if vim.bo.filetype == "tex" then
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

  -- Optionally force tex files to be recognized as latex
  if M.opts.tex2latex then
    -- Change tex to latex
    vim.api.nvim_create_autocmd({"FileType"}, {
      group = M.auid,
      pattern = {"tex"},
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

-- Cache for inline queries
local rnoweb_inline_query = nil
local pythontex_inline_query = nil

-- This function replaces inline R code with the results of that code
-- Supports both Rnoweb (\Sexpr) and PythonTeX (\py)
M.mask_inline = function()
  if info.ft == "rnoweb" then
    M.mask_inline_rnoweb()
  elseif info.ft == "latex" then
    M.mask_inline_pythontex()
  end
end

-- Rnoweb inline substitution (reads from ./inline/ directory)
M.mask_inline_rnoweb = function()
  -- Get the parser for this buffer
  local parser = vim.treesitter.get_parser(info.bufnr)
  local tree   = parser:parse()
  local root   = tree[1]:root()

  -- Cache query on first use
  if not rnoweb_inline_query then
    rnoweb_inline_query = q.parse("rnoweb", "(rinline (renv_content) @inline_content)")
  end

  local count = 0
  for _, match, _ in rnoweb_inline_query:iter_matches(root, info.bufnr) do
    for _, nodes in pairs(match) do
      count = count + 1
      local node = nodes[1]
      if node == nil then goto continue end
      local l0, c0, _, c1 = node:range()
      -- Get the text from inline results file
      local fname = "./inline/" .. count .. ".txt"
      local text = h.read_lines(fname)[1]
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

      h.mc_conceal(info.bufnr, info.ns, l0, c0, opts, clen)
      ::continue::
    end
  end
end

-- Parse pythontex .pytxmcr file to extract inline results
-- The file contains LaTeX macros with SaveVerbatim environments
-- We extract the content between \begin{SaveVerbatim} and \end{SaveVerbatim}
local function parse_pytxmcr(filepath)
  local results = {}
  local lines = h.read_lines(filepath)
  local in_verbatim = false
  local current_result = {}
  local current_key = nil

  for _, line in ipairs(lines) do
    -- Look for SaveVerbatim environment with key like {pytx@MCR@...}
    local key = line:match("\\begin{SaveVerbatim}{(pytx@MCR@[^}]+)}")
    if key then
      in_verbatim = true
      current_key = key
      current_result = {}
    elseif line:match("\\end{SaveVerbatim}") then
      if current_key then
        results[current_key] = table.concat(current_result, "\n")
      end
      in_verbatim = false
      current_key = nil
    elseif in_verbatim then
      table.insert(current_result, line)
    end
  end

  -- Also build an ordered list for positional matching
  local ordered = {}
  for _, line in ipairs(lines) do
    local key = line:match("\\begin{SaveVerbatim}{(pytx@MCR@py@default@default@%d+_[^}]+)}")
    if key and results[key] then
      table.insert(ordered, results[key])
    end
  end

  return ordered
end

-- PythonTeX inline substitution (reads from pythontex-files-<jobname>/)
M.mask_inline_pythontex = function()
  local parser = vim.treesitter.get_parser(info.bufnr)
  local tree   = parser:parse()
  local root   = tree[1]:root()

  -- Cache query on first use - matches \py{...} commands
  if not pythontex_inline_query then
    pythontex_inline_query = q.parse("latex", [[
      (generic_command
        (command_name) @cmd (#eq? @cmd "\\py")
        (curly_group) @content
      )
    ]])
  end

  -- Get the pythontex output directory based on current file
  local bufname = vim.api.nvim_buf_get_name(info.bufnr)
  local dir = vim.fn.fnamemodify(bufname, ":h")
  local jobname = vim.fn.fnamemodify(bufname, ":t:r")
  local pytx_dir = dir .. "/pythontex-files-" .. jobname

  -- Check if pythontex output directory exists
  if vim.fn.isdirectory(pytx_dir) == 0 then
    return
  end

  -- Read and parse the .pytxmcr file which contains inline results
  local results_file = pytx_dir .. "/" .. jobname .. ".pytxmcr"
  if not h.file_exists(results_file) then
    return
  end

  local inline_results = parse_pytxmcr(results_file)

  local count = 0
  for _, match, _ in pythontex_inline_query:iter_matches(root, info.bufnr) do
    for id, nodes in pairs(match) do
      local node = nodes[1]
      if node == nil then goto continue end

      -- We want the curly_group content, not the command name
      local capture_name = pythontex_inline_query.captures[id]
      if capture_name ~= "content" then goto continue end

      count = count + 1
      local parent = node:parent()
      local l0, c0, _, c1 = parent:range()
      local clen = c1 - c0

      -- Get result from pythontex output
      local text = inline_results[count]
      if text then
        -- Clean up the result (remove any trailing whitespace/newlines)
        text = text:gsub("%s+$", "")
      else
        -- No result yet - just show the expression without braces
        text = h.gtext(node):gsub("^{", ""):gsub("}$", "")
      end

      local opts = {
        end_col = c1,
        virt_text_pos = "overlay",
        virt_text_hide = true,
        conceal = text,
        hl_group = "@number"
      }

      h.mc_conceal(info.bufnr, info.ns, l0, c0, opts, clen)
      ::continue::
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
        for id, node in pairs(match) do
          node = node[1]
          -- Get the per-match metadata (if any)
          local mmeta = (meta and meta[id]) or {}
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
    info.save_state()
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
  local latex_cmd = string.format("latexmk -pdf -shell-escape %s", vim.fn.shellescape(tex_path))

  -- Combine both commands using a shell
  local full_cmd = string.format("%s && %s", knit_cmd, latex_cmd)

  -- Open terminal split and capture buffer number
  vim.cmd("botright new") -- opens a new empty buffer in a split
  local term_buf = vim.api.nvim_get_current_buf()

  -- Start the terminal job
  vim.fn.termopen(full_cmd, {
    on_exit = function(_, code, _)
      if code == 0 then
        -- Delay close to give terminal a chance to flush output
        vim.defer_fn(function()
          -- Make sure buffer still exists
          if vim.api.nvim_buf_is_loaded(term_buf) then
            vim.api.nvim_buf_delete(term_buf, { force = true })
          end
        end, 500) -- 500ms delay
      else
        print("Compile failed (exit code " .. code .. "). Terminal left open.")
      end
    end,
  })

end

-- Create a user command for easy invocation
vim.api.nvim_create_user_command("CompileRnw", M.compile_rnw, {})

-- PythonTeX compilation using latexmk
-- For automatic pythontex support, add to ~/.latexmkrc:
--   add_cus_dep('pytxcode', 'tex', 0, 'pythontex');
--   sub pythontex { return system("pythontex \"$_[0]\""); }
M.compile_pythontex = function()
  local tex_path = vim.api.nvim_buf_get_name(0)

  if not tex_path:match("%.tex$") then
    print("Current buffer is not a .tex file.")
    return
  end

  -- Simple latexmk invocation - pythontex rules should be in ~/.latexmkrc
  local full_cmd = string.format(
    "latexmk -pdf -shell-escape %s",
    vim.fn.shellescape(tex_path)
  )

  -- Open terminal split and capture buffer number
  vim.cmd("botright new")
  local term_buf = vim.api.nvim_get_current_buf()

  -- Start the terminal job
  vim.fn.termopen(full_cmd, {
    on_exit = function(_, code, _)
      if code == 0 then
        -- Delay close to give terminal a chance to flush output
        vim.defer_fn(function()
          if vim.api.nvim_buf_is_loaded(term_buf) then
            vim.api.nvim_buf_delete(term_buf, { force = true })
          end
        end, 500)
      else
        print("PythonTeX compile failed (exit code " .. code .. "). Terminal left open.")
      end
    end,
  })
end

-- Create a user command for PythonTeX compilation
vim.api.nvim_create_user_command("CompilePythonTeX", M.compile_pythontex, {})

-- Unified compile function that dispatches based on filetype
M.compile = function()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname:match("%.Rnw$") then
    M.compile_rnw()
  elseif bufname:match("%.tex$") then
    M.compile_pythontex()
  else
    print("Unsupported file type for compilation.")
  end
end

vim.api.nvim_create_user_command("Compile", M.compile, {})

return M

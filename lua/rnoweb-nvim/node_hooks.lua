local ts   = vim.treesitter
local q    = vim.treesitter.query
local sym  = require'rnoweb-nvim.symbols'
local h    = require'rnoweb-nvim.helpers'
local info = require'rnoweb-nvim.info'

local M = {}

local author_year = function(a)
  local out = {}
  for _, v in pairs(a) do
    local author = v:match('^([^%d]+)%d+')
    local year   = v:match('^[^%d]+(%d+)')
    out[#out+1] = {
      author = author,
      year = year,
    }
  end
  return(out)
end

M.citation = function(lang, node)

  local l0, c0, _, c1 = node:range()

  local clen  = c1 - c0
  local text = h.gtext(node)

  -- Is this a parencite?
  local is_paren = text:match("^\\parencite") and true or false

  -- The query for the author
  local kq = q.parse_query(lang, "(curly_group_text_list (text) @keys )")
  -- The query for any pre-notes
  local pq = q.parse_query(lang, "(brack_group (text) @prenote )")

  local keys = {}
  for _, v in kq:iter_captures(node, info.bufnr) do
    local k = h.gtext(v)
    keys[#keys+1] = k
  end

  keys = author_year(keys)

  -- Some citations will have a prenote
  local counter = 0
  for _, v in pq:iter_captures(node, info.bufnr) do
    counter = counter + 1
    keys[counter].pn = h.gtext(v)
  end

  for k, _ in pairs(keys) do
    keys[k].pn = keys[k].pn == nil and "" or ", p." .. keys[k].pn
  end

  local display = ""
  if is_paren then
    display = "("
    local lkeys = #keys
    for _, v in pairs(keys) do
      lkeys = lkeys - 1
      display = display .. v["author"] .. " " .. v["year"] .. v["pn"] .. (lkeys > 0 and ", " or "")
    end
    display = display .. ")"
  else
    local lkeys = #keys
    for _, v in pairs(keys) do
      lkeys = lkeys - 1
      display = display .. v["author"] ..
        " (" .. v["year"] ..
        v["pn"] ..
        ")" .. (lkeys > 0 and ", " or "")
    end
  end

  local opts = {
    end_col = c1,
    hl_group = "TSTextReference",
    virt_text_pos = "overlay",
    virt_text_hide = true,
    conceal = display
  }

  h.mc_conceal(
    info.bufnr,
    info.ns,
    l0,
    c0,
    opts,
    clen
  )
end

local conceal_cmd_fn = function(lang, node, cmd_name)

  -- Full range of the node
  local node_range = {node:range()}
  -- Node for the command name
  local cmd_node  = node:field("command")
  -- Rang of the command name
  local cmd_range = {cmd_node[1]:range()}
  -- Get the table of arg nodes
  local arg_nodes  = node:field("arg")
  -- Number of argument groups
  local nargs = #arg_nodes

  local text = sym.sym[lang][cmd_name]
  local ntext = #text

  -- Get the table of ranges for args
  local arg_ranges = {}
  if nargs > 0 then
    for i = 1,nargs do
      arg_ranges[#arg_ranges+1] = {arg_nodes[i]:range()}
    end
  end

  -- We always start at the beginning of the main node
  local beg_line = node_range[1]
  local beg_col  = node_range[2]

  local end_line
  local end_col

  if nargs == 0 or ntext == 1 then
    end_line = cmd_range[3]
    end_col  = cmd_range[4]
  else
    end_line = arg_ranges[1][1]
    end_col  = arg_ranges[1][2] + 1
  end

  local clen = end_col - beg_col

  -- Opening symbol
  local opts = {
    end_col = end_col,
    end_line = end_line,
    virt_text_pos = "overlay",
    virt_text_hide = true,
    conceal = text[1]
  }

  h.mc_conceal(
    info.bufnr,
    info.ns,
    beg_line,
    beg_col,
    opts,
    clen
  )

  if ntext == 1 then
    return(nil)
  end

  -- Loop through the args, applying conceals in order
  beg_line = node_range[1]
  beg_col  = node_range[2]

  for i = 1,nargs do

    beg_line = arg_ranges[i][3]
    beg_col  = arg_ranges[i][4]
    if i < nargs then
      end_line = arg_ranges[i][3]
      end_col  = arg_ranges[i][4] + 1
    else
      beg_col  = beg_col - 1
      end_line = arg_ranges[i][3]
      end_col  = arg_ranges[i][4]
    end


    text = sym.sym[lang][cmd_name][i + 1]

    -- Opening symbol
    opts = {
      end_col = end_col,
      end_line = end_line,
      virt_text_pos = "overlay",
      virt_text_hide = true,
      conceal = text
    }

    clen = end_col - beg_col

    h.mc_conceal(
      info.bufnr,
      info.ns,
      beg_line,
      beg_col,
      opts,
      clen
    )
  end

end

M.conceal_cmd = function(lang, node)

  local cmd_node = node:field("command")
  cmd_node = cmd_node[1]
  if cmd_node == nil then return nil end

  local cmd_name = ts.get_node_text(cmd_node, info.bufnr)

  if sym.sym[lang][cmd_name] ~= nil then
    conceal_cmd_fn(lang, node, cmd_name)
  end
end

return M

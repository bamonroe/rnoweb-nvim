local ts   = vim.treesitter
local q    = vim.treesitter.query
local sym  = require'rnoweb-nvim.symbols'
local h    = require'rnoweb-nvim.helpers'
local info = require'rnoweb-nvim.info'
local ss   = require'rnoweb-nvim.super_list'
local d    = require'rnoweb-nvim.dbug'

local M = {}

-- For simple conceals of a node with a given bit of text
local nconceal = function(n, text, offsets, range)

  -- Default offsets are 0
  local off = {
    bl = 0,
    el = 0,
    bc = 0,
    ec = 0,
  }

  -- Allow some adjustment
  if offsets ~= nil then
    for k, v in pairs(offsets) do
      off[k] = v
    end
  end


  -- Get the range of the curly gruoup and conceal it all
  if range == nil then
    range  = {n:range()}
  end
  local beg_line = range[1] + off.bl
  local end_line = range[3] + off.el
  -- As well as the carat or underscore character in the previous node
  local beg_col = range[2] + off.bc
  local end_col = range[4] + off.ec

  local opts = {
    end_col = end_col,
    end_line = end_line,
    virt_text_pos = "overlay",
    virt_text_hide = true,
    conceal = text
  }

  local clen = end_col - beg_col
  h.mc_conceal(
    info.bufnr,
    info.ns,
    beg_line,
    beg_col,
    opts,
    clen
  )

end

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

local find_type
find_type = function(n, type, recursive)

  if recursive == nil then
    recursive = false
  end

  local res = {}
  for child, _ in n:iter_children() do
    local val = child:type()
    if type == val then
      table.insert(res, child)
    end
    if child:child_count() > 0  and recursive then
      local nres = find_type(child, type, recursive)
      for _, nc in pairs(nres) do
        table.insert(res, nc)
      end
    end
  end
  return res
end

-- Format citations nicely
M.citation = function(lang, node, meta)

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

-- This is the main concealing function
local conceal_cmd_fn = function(lang, node, cmd_name)

  local field = "command"
  if lang == "rnoweb" then
    field = "Sexpr"
  end

  -- Full range of the node
  local node_range = {node:range()}
  -- Node for the command name
  local cmd_node  = node:field(field)
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

M.conceal_cmd = function(lang, node, _)

  local field = "command"
  if lang == "rnoweb" then
    field = "Sexpr"
  end

  local cmd_node = node:field(field)
  cmd_node = cmd_node[1]
  if cmd_node == nil then return nil end

  local cmd_name = ts.get_node_text(cmd_node, info.bufnr)

  if sym.sym[lang][cmd_name] ~= nil then
    conceal_cmd_fn(lang, node, cmd_name)
  end
end

-- Math delimter function
M.mdelimit = function(_, node, _)

  local nrange = {node:range()}

  local lchild = node:child(1)
  local lrange = {lchild:range()}
  local rchild = node:child(node:child_count() - 1)
  local rrange = {rchild:range()}

  local ldelim = h.gtext(lchild)
  local rdelim = h.gtext(rchild)

  local s = sym.sym.latex

  ldelim = s[ldelim] ~= nil and s[ldelim][1] or ldelim
  rdelim = s[rdelim] ~= nil and s[rdelim][1] or rdelim

  local beg_line = nrange[1]
  local end_line = lrange[1]

  local beg_col = nrange[2]
  local end_col = lrange[4]

  local opts = {
    end_col = end_col,
    end_line = end_line,
    virt_text_pos = "overlay",
    virt_text_hide = true,
    conceal = ldelim
  }

  local clen = end_col - beg_col
  h.mc_conceal(
    info.bufnr,
    info.ns,
    beg_line,
    beg_col,
    opts,
    clen
  )

  beg_line = rrange[1]
  end_line = nrange[3]

  beg_col = rrange[2] - 6
  end_col = nrange[4]

  opts = {
    end_col = end_col,
    end_line = end_line,
    virt_text_pos = "overlay",
    virt_text_hide = true,
    conceal = rdelim
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

M.single_hat = function(_, node, _)

  local little_hats = {}
    little_hats["a"] = "â"
    little_hats["A"] = "Â"
    little_hats["c"] = "ĉ"
    little_hats["C"] = "Ĉ"
    little_hats["e"] = "ê"
    little_hats["E"] = "Ê"
    little_hats["g"] = "ĝ"
    little_hats["G"] = "Ĝ"
    little_hats["i"] = "î"
    little_hats["I"] = "Î"
    little_hats["o"] = "ô"
    little_hats["O"] = "Ô"
    little_hats["s"] = "ŝ"
    little_hats["S"] = "Ŝ"
    little_hats["u"] = "û"
    little_hats["U"] = "Û"
    little_hats["w"] = "ŵ"
    little_hats["W"] = "Ŵ"
    little_hats["y"] = "ŷ"
    little_hats["Y"] = "Ŷ"


  local child = node:child(0)
  local text = h.gtext(child)

  local parent = node:parent():parent()

  nconceal(parent, little_hats[text])

end

local ss_get_res = function(n, kind)

  local res = ""

  local type = n:type()

  -- Actually, support only text/word until I can figure out how to remove overlapping extmarks
  if type == "text" or type == "word" then
    -- Change the text to superscripts if possible
    if type == "text" then
      local text = h.gtext(n)
      for letter in text:gmatch(".") do
        -- If the symbol is in the table, use it, otherwise go back to original
        letter = ss[kind][letter] and ss[kind][letter] or letter
        res = res .. letter
      end
    elseif type == "word" then
      local text = h.gtext(n)
      text = string.sub(text, -1)
      text = ss[kind][text] and ss[kind][text] or "_" .. text
      res = res .. text
    else
      local text = h.gtext(n)
      local letter = ss[kind][text] and ss[kind][text] or text
      res = res .. letter
    end
  end

  return res

end

M.subsuper = function(_, node, meta)

  local kind = meta["kind"]

  local range  = {node:range()}
  local offsets = {bc = -1}

  local res = ""
  if node:child_count() == 0 then
    res = ss_get_res(node, kind)
    -- There's only 1 character to be under-scored, so only conceal that char and the underscore
    range[3] = range[4] - 2
    offsets.bc = 0;
  else
    for child, _ in node:iter_children() do
      res = res .. ss_get_res(child, kind)
    end
  end

  nconceal(node, res, offsets, range)

end

M.footnote = function(_, node, _)

  info.counts.footnote = info.counts.footnote + 1

  local text = "" .. info.counts.footnote .. ""
  local kind = "superscript"
  local res = ""
  for letter in text:gmatch(".") do
    -- If the symbol is in the table, use it, otherwise go back to original
    letter = ss[kind][letter] and ss[kind][letter] or letter
    res = res .. letter
  end

  nconceal(node, res)

end

M.fig_lab_count = function(_, node, _)
  local lab = h.gtext(node)
  info.counts.figures = info.counts.figures + 1
  info.lab_numbers[lab] = info.counts.figures
end

M.section_count = function(_, node, _)
  info.counts.sections = info.counts.sections + 1
  local sec = info.counts.sections
  for c, _ in node:iter_children() do
    local type = c:type()
    if type == "label_definition" then
      local lab = c:field("name")[1]:child(1)
      lab = h.gtext(lab)
      info.lab_numbers[lab] = sec
    end
  end
end

M.math_count = function(_, node, _)

  -- What kind of math environment
  local beg  = node:field("begin")[1]
  local type = h.gtext(beg:field("name")[1]:child(1))

  -- Align environments are kinda tricky
  if type == "align" then
    info.counts.equations = info.counts.equations + 1
    local ldef = node:child(1)
    local ctx = ldef

    -- If the first child is a label definition, it gets assigned now,
    -- all subsequent label definitions are handled in the below loop
    if ldef:type() == "label_definition" then
      local lab = h.gtext(ldef:field("name")[1]:child(1))
      info.lab_numbers[lab] = info.counts.equations
      ctx = ldef:next_sibling()
    end

    -- If we hit a line break, we increment the equation number,
    -- if we hit a label definition, we assigned the label
    for c, _ in ctx:iter_children() do
      if c:type() == "generic_command" then
        local cmd = c:field("command")[1]
        local v = h.gtext(cmd)
        -- This was annoying, but the only way I could actuall test for a line
        -- break command
        local j = "\\\\"
        if v == j then
          info.counts.equations = info.counts.equations + 1
        end

      elseif c:type() == "label_definition" then
        local lab = h.gtext(c:field("name")[1]:child(1))
        info.lab_numbers[lab] = info.counts.equations
      end
    end

  -- Equation environments are much easier
  elseif type == "equation" then
    info.counts.equations = info.counts.equations + 1
    local ldef = find_type(node, "label_definition", true)
    if ldef[1] ~= nil then
      local lab = h.gtext(ldef[1]:field("name")[1]:child(1))
      info.lab_numbers[lab] = info.counts.equations
    end

  end

end

M.ref = function(_, node, _)

  -- Get the "names" of the reference (I'm assuming 1 arg references right
  -- now), and the first child will disclude the surrounding braces
  local lab = node:field("names")[1]:child(1)
  -- This is the reference
  lab = h.gtext(lab)

  -- See if its in the table
  local num = info.lab_numbers[lab]
  num = num and num or lab

  local text = "" .. num .. ""

  nconceal(node, text)

end

return M

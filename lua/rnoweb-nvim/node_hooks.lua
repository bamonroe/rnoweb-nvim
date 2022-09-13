local ts   = vim.treesitter
local q    = vim.treesitter.query
local sym  = require'rnoweb-nvim.symbols'
local h    = require'rnoweb-nvim.helpers'
local info = require'rnoweb-nvim.info'
local ss   = require'rnoweb-nvim.super_list'
local d    = require'rnoweb-nvim.dbug'

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

M.conceal_cmd = function(lang, node, meta)

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

-- I'm trying to keep track of the equation numbers above the environments
M.begin = function(lang, beg_node, meta)

  local cmd_node = beg_node:field("name")[1]:field("text")[1]
  local name = ts.get_node_text(cmd_node, info.bufnr)

  -- Currently just dealing with equations
  local v = h.in_tablev(name, {"equation", "align"})
  if not v  then return(nil) end

  local rname = name
  name = "math"

  -- Initialize if empty
  info["beg_env"] = info["beg_env"] == nil and {} or info["beg_env"]

  if info["beg_env"][name] == nil then
    info["beg_env"][name] = {
      count = 0,
    }
    info["beg_env"]["label"] = {}
  end
  --
  -- Always "math_environment" for equation begins, not always with a label
  local parent = beg_node:parent()

  -- If we're in an align environment, we need to count the number of line
  -- breaks in the top-level environment
  local count = 1
  if rname == "align" then
    for n in parent:iter_children() do
      local nt = n:type()
      if nt == "generic_command" then
        local cname = n:field("command")[1]
        cname = ts.get_node_text(cname, info.bufnr)
        if cname == "\\\\" then
          count = count + 1
        end
      end
    end
  end

  -- Increment
  local eqcount = info["beg_env"][name]["count"]
  local label_count = eqcount
  info["beg_env"][name]["count"] = info["beg_env"][name]["count"] + count

  for n in parent:iter_children() do
    if n:type() == "label_definition" then
      label_count = label_count + 1
      local label = n:field("name")[1]
      label = label:field("text")[1]
      label = ts.get_node_text(label, info.bufnr)
      info["beg_env"]["label"][label] = "" .. label_count .. ""
    end
  end

  -- Opening symbol
  local brange = {beg_node:range()}
  local text = " Equation"
  if count > 1 then
    text = text .. "s "
    for i = 1,count do
      if i == count then
        text = text .. (eqcount + i)
      else
        text = text .. (eqcount + i) .. ", "
      end
    end
  else
    text = text .. " " .. (eqcount + 1)
  end

  local opts = {
    end_line = brange[1],
    virt_text_pos = "eol",
    virt_text_hide = true,
    virt_text = {{text, "Conceal"}}
  }

  info.ids[#info.ids+1] = vim.api.nvim_buf_set_extmark(
    info.bufnr,
    info.ns,
    brange[1],
    brange[4],
    opts)

end

M.ref = function(lang, node, meta)

  local name = node:field("names")[1]
  name = name:field("text")[1]
  name = ts.get_node_text(name, info.bufnr)

  local val = info["beg_env"]["label"][name]

  -- If we haven't got a replacement for this ref, just skip it
  if val == nil then return nil end

  local beg_line, beg_col, end_line, end_col = node:range()

  local opts = {
    end_col = end_col,
    end_line = end_line,
    virt_text_pos = "overlay",
    virt_text_hide = true,
    conceal = val
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

-- Math delimter function
M.mdelimit = function(lang, node, meta)

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

M.single_hat = function(lang, node, meta)

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
  local range  = {parent:range()}


  local beg_line = range[1]
  local end_line = range[1]

  local beg_col = range[2]
  local end_col = range[4]

  local opts = {
    end_col = end_col,
    end_line = end_line,
    virt_text_pos = "overlay",
    virt_text_hide = true,
    conceal = little_hats[text]
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

M.subsuper = function(lang, node, meta)

  local kind = meta["kind"]

  local res = ""
  for child, _ in node:iter_children() do

    local type = child:type()

    -- Only suuport text or generic commands here
    --if type == "text" or type == "generic_command" then

    -- Actually, support only text until I can figure out how to remove overlapping extmarks
    if type == "text" then

      -- Change the text to superscripts if possible
      if type == "text" then
        local text = h.gtext(child)
        for letter in text:gmatch(".") do
          -- If the symbol is in the table, use it, otherwise go back to original
          letter = ss[kind][letter] and ss[kind][letter] or letter
          res = res .. letter
        end
      else
        local text = h.gtext(child)
        local letter = ss[kind][text] and ss[kind][text] or text
        res = res .. letter
      end

      -- Now get the range of the curly gruoup and conceal it all
      local range  = {node:range()}

      local beg_line = range[1]
      local end_line = range[1]

      -- As well as the carat or underscore character in the previous node
      local beg_col = range[2] - 1
      local end_col = range[4]

      local opts = {
        end_col = end_col,
        end_line = end_line,
        virt_text_pos = "overlay",
        virt_text_hide = true,
        conceal = res
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
  end

end

return M

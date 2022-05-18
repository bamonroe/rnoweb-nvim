local ts   = vim.treesitter
local q    = vim.treesitter.query
local sym  = require'rnoweb-nvim.symbols'
local h    = require'rnoweb-nvim.helpers'
local info = require'rnoweb-nvim.info'

local M = {}

M.replace = function(lang, node)

  local l0, c0, _, c1 = node:range()
  local clen  = c1 - c0
  local cmd = h.gtext(node)

  local text = sym.get(lang, cmd)
  if text == nil then return(nil) end

  text = string.sub(text, 1, clen)
  local slen = h.slen(text)
  local pad_amt = clen - slen

  -- local ptext = h.center_pad(text, pad_amt)

  local opts = {
    end_col = c1,
    virt_text = {{'', "Conceal"}},
    virt_text_pos = "overlay",
    virt_text_hide = true,
    conceal = text,
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

  -- I don't know why there seems to be a problem with column 0 marks
  c0 = c0 == 0 and 1 or c0

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

  local tlen = h.slen(display)
  local pad_amt = clen - tlen
  local ptext = h.center_pad(display, pad_amt)

  local opts = {
    end_col = c1,
    virt_text = {{ptext, "TSTextReference"}},
    virt_text_pos = "overlay",
    virt_text_hide = true,
  }
  info.ids[#info.ids+1] = vim.api.nvim_buf_set_extmark(info.bufnr, info.ns, l0, c0, opts)

end

local conceal_curly = function(lang, node, cmd)

  local left  = M.curly_cmd_pairs[cmd]["left"]
  local right = M.curly_cmd_pairs[cmd]["right"]

  -- Full range of the node
  local node_range = {node:range()}

  -- The range of the arg node
  local arg_node  = node:field("arg")[1]
  local arg_range = {arg_node:range()}

  -- Opening symbol
  local opts = {
    end_line = arg_range[1],
    end_col  = arg_range[2] + 1,
    virt_text = {{"", "Conceal"}},
    virt_text_pos = "overlay",
    virt_text_hide = true,
    conceal = left,
  }

  info.ids[#info.ids+1] = vim.api.nvim_buf_set_extmark(
    info.bufnr,
    info.ns,
    node_range[1],
    node_range[2],
    opts)

  -- Closing symbol
  opts = {
    end_line = arg_range[3],
    end_col  = arg_range[4],
    virt_text = {{"", "Conceal"}},
    virt_text_pos = "overlay",
    virt_text_hide = true,
    conceal = right,
  }

  info.ids[#info.ids+1] = vim.api.nvim_buf_set_extmark(
    info.bufnr,
    info.ns,
    arg_range[3],
    arg_range[4] - 1,
    opts)

end

M.curly_cmd_pairs = {}
M.curly_cmd_pairs["\\enquote"]  = {left = "“", right = "”"}
M.curly_cmd_pairs["\\textelp"]  = {left = "…", right = ""}
M.curly_cmd_pairs["\\textit"]   = {left = "",  right = ""}
M.curly_cmd_pairs["\\mathit"]   = {left = "",  right = ""}
M.curly_cmd_pairs["\\text"]     = {left = "",  right = ""}

M.curly_cmd = function(lang, node)
  local cmd_node = node:field("command")[1]
  local cmd_name = ts.get_node_text(cmd_node, info.bufnr)
  if M.curly_cmd_pairs[cmd_name] ~= nil then
    conceal_curly(lang, node, cmd_name)
  else
    return nil
  end
end

return M

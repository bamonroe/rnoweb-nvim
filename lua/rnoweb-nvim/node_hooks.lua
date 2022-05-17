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

  local ptext = h.center_pad(text, pad_amt)

  local opts = {
    end_col = c1,
    virt_text = {{ptext, "Conceal"}},
    virt_text_pos = "overlay",
    virt_text_hide = true,
  }

  -- Conceal values where the replacement text is 0 or 1 in char length
  if slen < 2 then
    opts["conceal"] = text
    opts["virt_text"] = {{"", "Conceal"}}
  end

  info.ids[#info.ids+1] = vim.api.nvim_buf_set_extmark(info.bufnr, info.ns, l0, c0, opts)
end

return M

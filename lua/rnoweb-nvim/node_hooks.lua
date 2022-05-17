local sym  = require'rnoweb-nvim.symbols'
local h    = require'rnoweb-nvim.helpers'
local info = require'rnoweb-nvim.info'

local M = {}

M.cmd = function(lang, node, cmd)

  local l0, c0, _, c1 = node:range()
  local clen  = c1 - c0

  local text = sym.get(lang, cmd)
  text = string.sub(text, 1, clen)
  local pad_amt = clen - h.slen(text)

  text = h.center_pad(text, pad_amt)

  local opts = {
    end_col = c1,
    virt_text = {{text, "Conceal"}},
    virt_text_pos = "overlay",
    virt_text_hide = true,
  }
  info.ids[#info.ids+1] = vim.api.nvim_buf_set_extmark(info.bufnr, info.ns, l0, c0, opts)
end

return M

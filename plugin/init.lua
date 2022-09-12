local v = vim.api
local rnw = require('rnoweb-nvim')

v.nvim_create_autocmd({"CursorHold", "BufEnter", "BufWritePost"}, {
  group = rnw.auid,
  pattern = {"*.Rnw", "*.tex"},
  callback = function()
    if rnw.opts.setup then
      if rnw.opts.tex2latex then
      rnw.tex2latex()
      end
      require('rnoweb-nvim').refresh()
    end
  end
})

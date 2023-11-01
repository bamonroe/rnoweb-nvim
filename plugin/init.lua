local v = vim.api
local rnw = require('rnoweb-nvim')


--these are convienience functions I use when debugging, I'll keep them commented out, but I don't want to delete the code

--[[
vim.keymap.set('n', ' 5', function()
  require('lazy.core.loader').reload("rnoweb-nvim")
  vim.print("refreshed rnw")
end)
vim.keymap.set('n', ' 1', function()
  vim.print("in 1")
  rnw.test()
end)
--]]


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

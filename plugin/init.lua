local v = vim.api
local rnw = require('rnoweb-nvim')
local info = require('rnoweb-nvim.info')


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


-- Main autocmd for refreshing conceals
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

-- Clean up buffer state when buffer is deleted
v.nvim_create_autocmd({"BufDelete"}, {
  group = rnw.auid,
  pattern = {"*.Rnw", "*.tex"},
  callback = function(args)
    info.on_buf_delete(args.buf)
  end
})

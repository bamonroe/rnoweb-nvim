local v = vim.api
local id = v.nvim_create_augroup("rnoweb-nvim-pkg", {
  clear = true,
})

v.nvim_create_autocmd({"CursorHold", "BufEnter", "BufWritePost"}, {
  group = id,
  pattern = {"*.Rnw"},
  callback = function()
    require('rnoweb-nvim').refresh()
  end
})

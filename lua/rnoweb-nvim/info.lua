local M = {
  iset = false
}

M.set_info = function()
  if M.iset == false then
    local bn = vim.api.nvim_get_current_buf()
    M.ft    = vim.bo.filetype
    M.ns    = vim.api.nvim_create_namespace("rnoweb-nvim")
    M.bufnr = bn
    M.ids   = {}
    M.footnote = 0
    M.iset  = true
  end
end

return M

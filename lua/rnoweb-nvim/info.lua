local M = {
  iset = false
}

M.reset = function()
    M.ids   = {}
    M.lab_numbers = {}
    M.counts = {
      footnote = 0,
      figures = 0,
      sections = 0,
      equations = 0,
    }
end

M.set_info = function()
  if M.iset == false then
    local bn = vim.api.nvim_get_current_buf()
    M.ft    = vim.bo.filetype
    M.ns    = vim.api.nvim_create_namespace("rnoweb-nvim")
    M.bufnr = bn
    M.iset  = true
    M.reset()
  end
end

return M

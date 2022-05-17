local M = {
  ns    = vim.api.nvim_create_namespace("rnoweb-nvim"),
  bufnr = vim.api.nvim_get_current_buf(),
  ids = {}
}

return M

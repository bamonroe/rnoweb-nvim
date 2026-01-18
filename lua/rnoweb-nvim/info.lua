local M = {
  ns = vim.api.nvim_create_namespace("rnoweb-nvim"),
  -- Per-buffer state tracking
  buffers = {},
}

-- Get or create buffer-specific state
M.get_buf_state = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not M.buffers[bufnr] then
    M.buffers[bufnr] = {
      ids = {},
      lab_numbers = {},
      counts = {
        footnote = 0,
        figures = 0,
        sections = 0,
        equations = 0,
      },
      last_macro_tick = 0,
    }
  end
  return M.buffers[bufnr]
end

M.reset = function()
  local state = M.get_buf_state(M.bufnr)
  state.ids = {}
  state.lab_numbers = {}
  state.counts = {
    footnote = 0,
    figures = 0,
    sections = 0,
    equations = 0,
  }
end

-- Update info for current buffer (called on every refresh)
M.set_info = function()
  local bn = vim.api.nvim_get_current_buf()
  M.bufnr = bn
  M.ft = vim.bo.filetype

  -- Get buffer-specific state
  local state = M.get_buf_state(bn)
  M.ids = state.ids
  M.lab_numbers = state.lab_numbers
  M.counts = state.counts
  M.last_macro_tick = state.last_macro_tick
end

-- Save state back to buffer table (call after modifications)
M.save_state = function()
  if M.bufnr and M.buffers[M.bufnr] then
    M.buffers[M.bufnr].ids = M.ids
    M.buffers[M.bufnr].lab_numbers = M.lab_numbers
    M.buffers[M.bufnr].counts = M.counts
    M.buffers[M.bufnr].last_macro_tick = M.last_macro_tick
  end
end

-- Clean up when buffer is deleted
M.on_buf_delete = function(bufnr)
  M.buffers[bufnr] = nil
end

return M

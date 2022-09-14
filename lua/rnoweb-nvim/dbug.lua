M = {}

M.print = function(line)

  local fp = io.open("/tmp/dbug", "a")

  if fp ~= nil then
    line = vim.inspect(line)
    fp:write(line .. ":nl:")
    fp:flush()
    fp:close()
  end
end

return M

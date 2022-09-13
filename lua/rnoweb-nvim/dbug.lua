M = {}

M.print = function(line)

  local fp = io.open("/tmp/dbug", "a")

  line = vim.inspect(line)

  if fp ~= nil then
    fp:write(line .. ":nl:")
    fp:flush()
    fp:close()
  end
end

return M

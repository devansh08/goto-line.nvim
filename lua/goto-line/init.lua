local M = {}

function M.GotoLine()
  ---@type string
  local line = vim.fn.getline(".")
  ---@type integer
  local col = vim.fn.col(".")

  ---@type string
  local file_path_matcher = "[^%%#&{}\\<>*%?$!:@+`|=^]+:%d+"
  ---@type string
  local file_path_matcher_no_spaces = "[^%%#&{}\\<>*%?$!:@+`|=^%s]+:%d+"

  -- Using prefix table instead of `|` operator, since Lua RegEx implementation is non-POSIX and does not support it
  ---@type string[]
  local matcher_prefix = { "/", "%./", "%.%./", "~", "" }

  for _, prefix in ipairs(matcher_prefix) do
    for _, pattern in ipairs({ file_path_matcher, file_path_matcher_no_spaces }) do
      ---@type integer|nil, integer|nil
      local start, finish = line:find(prefix .. pattern)

      if start ~= nil and col >= start and col <= finish then
        ---@type string
        local str = line:sub(start, finish)
        ---@type string, string
        local filename, line_number = str:match("(.*):(%d+)")
        if filename ~= nil and line_number ~= nil then
          -- Expand `~` as uv.fs_stat does not expand it
          filename = vim.fn.expand(filename)

          ---@type uv.fs_stat.result|nil, string|nil, any
          local stat, err, err_name = vim.uv.fs_stat(filename)
          if stat ~= nil and stat.type == "file" then
            -- Open file in current buffer
            vim.cmd("e " .. filename)
            vim.cmd(line_number)
          elseif err ~= nil or err_name ~= nil then
            print("[GotoLine] ERROR: Failed to stat file `" .. filename .. "`: " .. err_name .. ": " .. err)
          end
        end
      end
    end
  end
end

function M.setup()
  vim.api.nvim_create_user_command("GotoLine", M.GotoLine, {})
end

return M

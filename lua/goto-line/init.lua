local M = {}

---@type GotoLineOpts|{}
M.opts = {}

---@type table<OpenCmd, string>
M.open_cmd = {
  ["edit"] = "e",
  ["drop"] = "drop",
  ["tab-drop"] = "tab drop",
}

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

  ---@type boolean
  local matched = false
  for _, prefix in ipairs(matcher_prefix) do
    if not matched then
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
            local stat = vim.uv.fs_stat(filename)
            if stat ~= nil and stat.type == "file" then
              -- Escape whitespace
              filename = filename:gsub(" ", "\\ ")

              vim.cmd(M.open_cmd[M.opts.open_cmd] .. " " .. filename)
              vim.cmd(line_number)

              matched = true
              break
            end
          end
        end
      end
    end
  end
end

---@alias OpenCmd "edit"|"drop"

---@class GotoLineOpts
--- define the command to open the file [default = "drop"]
--- - `edit`: will open the file in the current buffer (`:help :edit`)
--- - `drop`: will switch to an existing buffer which has the file already open;
---         else it will open the file in the current buffer (`:help :drop`)
--- - `tab-drop`: will switch to an existing tab page which has the file already open;
---             else it will open the file in the current tab-page (`:help :drop`)
---@field open_cmd OpenCmd

---@param opts GotoLineOpts
function M.setup(opts)
  M.opts = {
    open_cmd = opts.open_cmd or "drop",
  }

  vim.api.nvim_create_user_command("GotoLine", M.GotoLine, {})
end

return M

local M = {}

---@type GotoLineOpts|{}
local global_opts = {}

---@type table<OpenCmd, string>
local open_cmd_map = {
  ["edit"] = "e",
  ["drop"] = "drop",
  ["tab-drop"] = "tab drop",
}

---@param args vim.api.keyset.create_user_command.command_args
local function GotoLine(args)
  local is_visual = args.range > 0

  ---@type string
  local line = vim.fn.getline(".")
  ---@type integer
  local col = vim.fn.col(".")

  if is_visual then
    ---@type integer[]
    local start_pos = vim.fn.getpos("'<")
    ---@type integer[]
    local end_pos = vim.fn.getpos("'>")

    ---@type string|string[]
    local lines = vim.fn.getline(start_pos[2], end_pos[2])

    if type(lines) == "table" then
      lines[1] = lines[1]:sub(start_pos[3], -1)
      if start_pos[2] ~= end_pos[2] then
        lines[#lines] = lines[#lines]:sub(1, end_pos[3])
      end

      line = table.concat(lines, "")
    else
      line = lines
    end
  end

  ---@type string
  local file_path_vimgrep_matcher = "[^%%#&{}\\<>*%?$!:@+`|=^]+:%d+:%d+"
  ---@type string
  local file_path_vimgrep_matcher_no_spaces = "[^%%#&{}\\<>*%?$!:@+`|=^%s]+:%d+:%d+"
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
      -- Check for vimgrep style first
      for i, pattern in ipairs({
        file_path_vimgrep_matcher,
        file_path_vimgrep_matcher_no_spaces,
        file_path_matcher,
        file_path_matcher_no_spaces,
      }) do
        ---@type integer|nil, integer|nil
        local start, finish = line:find(prefix .. pattern)

        if start ~= nil and (is_visual or (col >= start and col <= finish)) then
          ---@type string
          local str = line:sub(start, finish)
          ---@type string, string, string
          local filename, line_number, col_number = "", "", ""

          -- Vimgrep style
          if i <= 2 then
            filename, line_number, col_number = str:match("(.*):(%d+):(%d+)")
          else
            filename, line_number = str:match("(.*):(%d+)")
          end

          if filename ~= nil and line_number ~= nil then
            -- Expand `~` as uv.fs_stat does not expand it
            filename = vim.fn.expand(filename):match("^%s*(.-)%s*$")

            ---@type uv.fs_stat.result|nil, string|nil, any
            local stat = vim.uv.fs_stat(filename)
            if stat ~= nil and stat.type == "file" then
              -- Escape whitespace
              filename = filename:gsub(" ", "\\ ")

              if global_opts.pre_jump ~= nil and global_opts.pre_jump ~= "" then
                if type(global_opts.pre_jump) == "string" then
                  vim.cmd(global_opts.pre_jump)
                else
                  global_opts.pre_jump()
                end
              end

              vim.cmd(open_cmd_map[global_opts.open_cmd] .. " " .. filename)
              if col_number ~= "" then
                vim.api.nvim_win_set_cursor(0, { tonumber(line_number), col_number - 1 })
              else
                vim.cmd(line_number)
              end

              matched = true
              break
            end
          end
        end
      end
    end
  end

  -- Falling back to builtin `gf`
  if matched == false then
    vim.api.nvim_feedkeys("gf", "n", false)
  end
end

---@alias OpenCmd "edit"|"drop"|"tab-drop"

---@class GotoLineOpts
--- Define the command to open the file [default = "drop"]
--- - `edit`: will open the file in the current buffer (`:help :edit`)
--- - `drop`: will switch to an existing buffer which has the file already open;
---         else it will open the file in the current buffer (`:help :drop`)
--- - `tab-drop`: will switch to an existing tab page which has the file already open;
---             else it will open the file in the current tab-page (`:help :drop`)
---@field open_cmd OpenCmd
--- Define the command or function to run before the jump [optional]
--- Eg.: If running from terminal buffer (like `ToggleTerm`), close the buffer before jump
---@field pre_jump string|function?

---@param opts GotoLineOpts
function M.setup(opts)
  global_opts = {
    open_cmd = opts.open_cmd or "drop",
    pre_jump = opts.pre_jump or nil,
  }

  vim.api.nvim_create_user_command("GotoLine", GotoLine, {
    range = true,
  })
end

return M

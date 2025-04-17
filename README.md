# goto-line.nvim

Simple plugin that opens the file and goes to a line from the filepath and line number, under the cursor (extending builtin `gf`).
It looks for paths in the common error stacktrace format like `<filename>:<line_number>`, where `filename` can be absolute or relative, and with or without spaces (tries for best match).

## Installation

Install using your favorite package manager, like any other plugin.

For example, with `lazy.nvim`:
```lua
{
  "devansh08/goto-line.nvim",
  branch = "main",
  ---@type GotoLineOpts
  opts = {
    -- define the command to open the file [default = "drop"]
    -- - `edit`: will open the file in the current buffer (`:edit`)
    -- - `drop`: will switch to an existing buffer which has the file already open;
    --         else it will open the file in the current buffer (`:drop`)
    open_cmd = "drop",
  },
}
```

## Usage

The plugin provides the command `:GotoLine`, which will attempt to open the file and goto line, based on the current cursor position.

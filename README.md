# goto-line.nvim

Simple plugin that opens the file and goes to a line from the filepath and line number, under the cursor (extending builtin `gf`).
It looks for paths in the common error stacktrace format like `<filename>:<line_number>` or vimgrep format like `<filename>:<line_number>:<col_number>`, where `filename` can be absolute or relative, and with or without spaces (tries for best match).

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
    -- - `edit`: will open the file in the current buffer (`:help :edit`)
    -- - `drop`: will switch to an existing buffer which has the file already open;
    --         else it will open the file in the current buffer (`:help :drop`)
    -- - `tab-drop`: will switch to an existing tab page which has the file already open;
    --             else it will open the file in the current tab-page (`:help :drop`)
    open_cmd = "drop",
  },
}
```

## Usage

The plugin provides the command `:GotoLine`, which will attempt to open the file and goto line, based on the current cursor position.

Best matching is done with preference for vimgrep format over stacktrace format and considering spaces over not considering spaces.

In case the plugin is not able to match any valid file path, it will fallback to vim's builtin `gf`.

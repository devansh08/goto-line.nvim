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
  opts = {},
}
```

## Usage

The plugin provides the command `:GotoLine`, which will attempt to open the file and goto line, based on the current cursor position.

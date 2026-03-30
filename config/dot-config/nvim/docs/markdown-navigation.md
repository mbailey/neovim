# Markdown Link Navigation in Neovim

This guide explains how to set up Neovim to enable pressing Enter on markdown links to open the linked files.

## Prerequisites

- Neovim (0.7.0+)
- A plugin manager (packer, lazy.nvim, etc.)

## Installation

This functionality is provided by the [mkdnflow.nvim](https://github.com/jakewvincent/mkdnflow.nvim) plugin.

### Using lazy.nvim (recommended)

Add this to your Neovim plugin configuration:

```lua
{
  "jakewvincent/mkdnflow.nvim",
  ft = { "markdown" },
  config = function(_, opts)
    require("mkdnflow").setup(opts)
  end,
  opts = {
    links = {
      style = "markdown",
      relative_to = "current",
    },
    mappings = {
      MkdnEnter = { { "n", "v" }, "<CR>" }, -- Follow link under cursor
      MkdnNextLink = { "n", "<Tab>" },      -- Find next link
      MkdnPrevLink = { "n", "<S-Tab>" },    -- Find previous link
      MkdnGoBack = { "n", "<BS>" },         -- Go back to previous position
    },
    perspective = {
      priority = "current",
      fallback = "current",
    },
  },
}
```

### Using other plugin managers

For packer:
```lua
use {
  'jakewvincent/mkdnflow.nvim',
  config = function()
    require('mkdnflow').setup({
      links = {
        style = "markdown",
        relative_to = "current",
      },
      mappings = {
        MkdnEnter = { { "n", "v" }, "<CR>" },
      },
      perspective = {
        priority = "current",
        fallback = "current",
      },
    })
  end
}
```

## Key Features

The plugin provides these markdown-specific features:

- **⏎ (Enter key)**: Open the markdown link under cursor
- **Tab/Shift+Tab**: Navigate to next/previous link
- **Backspace**: Go back to previous position
- **]]** and **[[**: Navigate between headings
- **+** and **-**: Increase/decrease heading level
- **Ctrl+Space**: Toggle to-do items

## Detailed Configuration Options

For a fully-featured setup, here's a comprehensive configuration:

```lua
{
  -- Config values
  links = {
    style = "markdown",           -- 'markdown', 'wiki', or a table of options
    name_is_source = false,       -- Use file name as link text by default
    conceal = false,              -- Use Neovim's conceal feature for links
    context = 0,                  -- Lines of context to provide
    implicit_extension = false,   -- Don't add .md to implicit links
    transform_implicit = false,   -- Transform implicit links
    transform_explicit = false,   -- Transform explicit links
    relative_to = "current",      -- Create links relative to the current file
    absolute = false,             -- Force absolute paths
  },
  mappings = {
    MkdnEnter = { { "n", "v" }, "<CR>" },         -- Follow link under cursor
    MkdnNextLink = { "n", "<Tab>" },              -- Find next link
    MkdnPrevLink = { "n", "<S-Tab>" },            -- Find previous link
    MkdnNextHeading = { "n", "]]" },              -- Go to next heading
    MkdnPrevHeading = { "n", "[[" },              -- Go to previous heading
    MkdnGoBack = { "n", "<BS>" },                 -- Go back to previous position
    MkdnGoForward = { "n", "<Del>" },             -- Go forward to next position
    MkdnCreateLinkFromClipboard = { { "n", "v" }, "<leader>p" }, -- Paste link
    MkdnDestroyLink = { "n", "<M-CR>" },          -- Destroy link under cursor
    MkdnToggleToDo = { { "n", "v" }, "<C-Space>" }, -- Toggle to-do status
  },
  perspective = {
    priority = "current",         -- Prioritize current file
    fallback = "current",
  },
}
```

## Troubleshooting

If Enter key navigation isn't working:

1. Make sure the file is recognized as markdown:
   - Check with `:echo &filetype` - should return "markdown"
   - If not, ensure your markdown files have .md extension

2. Check if the plugin is loaded:
   - Run `:lua print(package.loaded['mkdnflow'] ~= nil)`
   - Should return "true"

3. Verify the mapping is active:
   - Run `:nmap <CR>` to see what Enter is mapped to
   - Should show the mkdnflow mapping

## Advanced Usage Tips

1. Create a debug command to help troubleshoot path resolution:

```lua
vim.api.nvim_create_user_command("MkdnDebugPath", function()
  local current_file = vim.fn.expand('%:p')
  local current_dir = vim.fn.expand('%:p:h')
  local cwd = vim.fn.getcwd()
  
  vim.notify("Current file: " .. current_file, vim.log.levels.INFO)
  vim.notify("Current directory: " .. current_dir, vim.log.levels.INFO)
  vim.notify("Working directory: " .. cwd, vim.log.levels.INFO)
end, {})
```

2. Customize the plugin further with the full configuration options from the [mkdnflow documentation](https://github.com/jakewvincent/mkdnflow.nvim)
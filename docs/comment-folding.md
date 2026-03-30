# Comment Folding/Hiding in Neovim

There are several ways to handle comment visibility in Neovim:

## Basic Fold Commands

These work with any folding method:
- `zc` - Close/collapse fold under cursor
- `zo` - Open/expand fold under cursor
- `za` - Toggle fold under cursor
- `zM` - Close all folds
- `zR` - Open all folds

## Treesitter (Recommended Modern Approach)

Our default configuration includes Treesitter with custom commands for managing comments:

- `:HideComments` - Hide all comments in the current file
- `:ShowComments` - Show all hidden comments

You can also use the standard fold commands for more granular control:
- `zc` - Close/collapse fold under cursor
- `zo` - Open/expand fold under cursor
- `za` - Toggle fold under cursor

## Legacy Built-in Method

For simple comment folding without Treesitter:
```vim
:set foldmethod=expr
:set foldexpr=getline(v:lnum)=~'^\\s*#'?1:0
```

Note: This basic approach only works with '#' style comments and doesn't understand code structure.

## Additional Features

### Comment Toggle Plugin

For quick comment toggling, consider adding the [Comment.nvim](https://github.com/numToStr/Comment.nvim) plugin to your `init.lua`:
- `gcc` - Toggle comment for current line
- `gc` - Toggle comment for selection in visual mode

### Persistence Tips

To customize how folds behave between sessions, you can add these settings to your `init.lua`:
```lua
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldenable = false  -- Start with folds open
```

## Further Resources

- `:help fold` - Built-in Neovim documentation for folding
- `:help fold-commands` - List of all folding commands
- [Treesitter Documentation](https://github.com/nvim-treesitter/nvim-treesitter) - Advanced folding and syntax features

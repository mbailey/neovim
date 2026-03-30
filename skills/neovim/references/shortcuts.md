# Neovim Shortcuts

The [leader](leader.md) key is a special prefix for custom keyboard shortcuts that defaults to backslash (`\`).

## Quick Reference (Essential)

| Shortcut           | Description                    |
| ------------------ | ------------------------------ |
| `<leader><space>`  | Command palette                |
| `<leader>e`        | Toggle file explorer           |
| `<leader>,`        | Switch between buffers         |
| `<C-w>w`           | Switch between windows/panes   |
| `<C-o>` / `<C-i>`  | Navigate back/forward in jumps |

## File Management

| Shortcut       | Description                     |
| -------------- | ------------------------------- |
| `<leader>e`    | Show/hide file explorer         |
| `<leader>f`    | Show current file in explorer   |
| `<leader>fc`   | Find config files               |
| `<leader>,`    | Switch between open buffers     |

## Navigation & Search

| Shortcut           | Description                     |
| ------------------ | ------------------------------- |
| `<leader><space>`  | Command palette (fuzzy finder)  |
| `<C-o>`            | Jump back in history            |
| `<C-i>`            | Jump forward in history         |
| `:jumps`           | List all jumps                  |
| `gf`               | Follow link under cursor        |

## Text Editing

| Shortcut     | Description                       |
| ------------ | --------------------------------- |
| `gw}`        | Format to end of paragraph        |
| `+y`         | Copy to system clipboard          |
| `+p`         | Paste from system clipboard       |

## Window Management

### Creating Splits

| Shortcut       | Description                          |
| -------------- | ------------------------------------ |
| `:split`       | Horizontal split (current file)      |
| `:vsplit`      | Vertical split (current file)        |
| `<C-w>s`       | Horizontal split (keyboard shortcut) |
| `<C-w>v`       | Vertical split (keyboard shortcut)   |
| `:split file`  | Open file in horizontal split        |
| `:vsplit file` | Open file in vertical split          |

### Navigating Splits

| Shortcut   | Description              |
| ---------- | ------------------------ |
| `<C-w>w`   | Switch between windows   |
| `<C-w>h`   | Move to left window      |
| `<C-w>l`   | Move to right window     |
| `<C-w>j`   | Move to window below     |
| `<C-w>k`   | Move to window above     |

## Development Tools

| Shortcut      | Description                     |
| ------------- | ------------------------------- |
| `<leader>l`   | Open Lazy plugin manager        |
| `<leader>ud`  | Toggle diagnostics              |
| `<leader>um`  | Toggle markdown mode            |

## Context-Specific Shortcuts

### File Explorer (nvim-tree)
*These shortcuts only work when the explorer is focused*

| Shortcut | Description              |
| -------- | ------------------------ |
| `a`      | Add new file             |
| `A`      | Add new directory        |
| `s`      | Open in horizontal split |
| `v`      | Open in vertical split   |

### Markdown Mode

| Shortcut       | Description                              |
| -------------- | ---------------------------------------- |
| `gf`           | Follow markdown link                     |
| `<leader>me`   | Extract selection to new file with link |

# Neovim Appearance

Neovim configuration for automatic light/dark theme switching.

## Auto-Detection

The `lua/config/theme-auto.lua` module provides automatic theme switching based on OS appearance.

### Detection Order
1. **macOS**: Reads `AppleInterfaceStyle` via `defaults` command
2. **Linux**: Checks GNOME `gsettings` for gtk-theme and color-scheme
3. **Terminal Fallback**: Analyzes terminal background color via `COLORFGBG` or highlight detection
4. **Default**: Falls back to dark if detection fails

### Auto-Refresh
Theme is re-detected on `FocusGained` event, so switching windows after changing OS theme will update Neovim.

## Quick Reference

### Manual Override
```vim
:set background=dark
:set background=light
```

### Force Re-Detection
```vim
:lua require("config.theme-auto").set_theme_auto()
```

## Configuration

In init.lua:
```lua
-- Enable auto-detection (default behavior)
require("config.theme-auto")

-- Or set manually and disable auto-detection
vim.o.background = "dark"  -- or "light"
```

## Colorscheme

The auto-detection sets `vim.o.background` which most colorschemes respect. The actual colorscheme is configured separately in your Neovim config.

## Source Code

The theme-auto module is at:
`config/dot-config/nvim/lua/config/theme-auto.lua`

## See Also

- [appearance package](../../appearance/README.md) - Central appearance management
- [appearance skill](../../appearance/SKILL.md) - AI-assisted appearance configuration

-- Automatic theme detection based on terminal background or GNOME dark mode preference
-- This module provides automatic switching between light and dark themes

local M = {}

-- Function to detect macOS dark mode preference
function M.detect_macos_dark_mode()
  local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    -- If AppleInterfaceStyle is "Dark", dark mode is enabled
    -- If the command fails (light mode), result will be empty or contain an error
    if result and result:find("Dark") then
      return true
    end
  end
  return false
end

-- Function to detect GNOME dark mode preference
function M.detect_gnome_dark_mode()
  -- Check color-scheme preference first (GNOME 42+) - this is the authoritative setting
  local handle = io.popen("gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    if result then
      if result:find("prefer%-dark") then
        return true
      elseif result:find("prefer%-light") or result:find("'default'") then
        return false
      end
    end
  end

  -- Fallback: Check gtk-theme (for older GNOME versions without color-scheme)
  handle = io.popen("gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    -- Check if the theme name contains 'dark'
    if result and result:lower():find("dark") then
      return true
    end
  end

  return false
end

-- Function to detect terminal background
function M.detect_terminal_background()
  -- Try to get terminal background color
  local bg = vim.fn.synIDattr(vim.fn.hlID("Normal"), "bg")
  if bg and bg ~= "" then
    -- Convert to RGB and check if it's dark
    local r, g, b = bg:match("#(%x%x)(%x%x)(%x%x)")
    if r and g and b then
      r = tonumber(r, 16)
      g = tonumber(g, 16) 
      b = tonumber(b, 16)
      -- Calculate luminance
      local luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
      return luminance < 0.5
    end
  end
  
  -- Check COLORFGBG environment variable (used by some terminals)
  local colorfgbg = vim.env.COLORFGBG
  if colorfgbg then
    local bg_color = colorfgbg:match(";(%d+)$")
    if bg_color then
      -- Terminal color indices: 0-7 are dark, 8-15 are light
      return tonumber(bg_color) < 8
    end
  end
  
  return nil
end

-- Function to set theme based on detection
function M.set_theme_auto()
  local is_dark = nil

  -- First try macOS detection if on Mac
  if vim.fn.has("mac") == 1 then
    is_dark = M.detect_macos_dark_mode()
  else
    -- Try GNOME detection on Linux
    is_dark = M.detect_gnome_dark_mode()
  end

  -- If OS detection didn't work, try terminal detection
  if is_dark == nil then
    is_dark = M.detect_terminal_background()
  end

  -- Default to dark if we couldn't detect
  if is_dark == nil then
    is_dark = true
  end

  -- Set the background
  if is_dark then
    vim.o.background = "dark"
  else
    vim.o.background = "light"
  end
end

-- Auto-detect on startup
M.set_theme_auto()

-- Re-detect when focus is gained (in case user changed system theme)
vim.api.nvim_create_autocmd("FocusGained", {
  callback = function()
    M.set_theme_auto()
  end,
  desc = "Auto-detect theme when Neovim gains focus"
})

return M
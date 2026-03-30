-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- WSL-aware clipboard configuration
if vim.fn.has("wsl") == 1 then
  -- Use clip.exe for WSL clipboard integration
  vim.g.clipboard = {
    name = "WslClipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }

  -- Make the unnamed register use the + register automatically
  vim.opt.clipboard:append("unnamedplus")
else
  -- Standard clipboard setting for non-WSL environments
  vim.opt.clipboard = "unnamedplus"
end

if vim.fn.has("mac") == 1 then
  vim.opt.clipboard = "unnamedplus"
  -- Explicitly set the clipboard provider for macOS
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = {
      ["+"] = "pbcopy",
      ["*"] = "pbcopy",
    },
    paste = {
      ["+"] = "pbpaste",
      ["*"] = "pbpaste",
    },
    cache_enabled = 0,
  }
  
  -- Enable mouse support for all modes
  vim.opt.mouse = "a"

  -- Fix jumpy scrolling in tmux on macOS (especially M-series MacBooks)
  -- Without these settings, scrolling appears to jump rather than flow smoothly
  vim.opt.smoothscroll = true        -- Enable Neovim's smooth scrolling feature (requires Neovim 0.10+)

  -- Configure scrolling behavior for better performance
  vim.opt.scrolloff = 8       -- Keep 8 lines above/below cursor when scrolling
  vim.opt.sidescrolloff = 8   -- Keep 8 columns left/right of cursor when scrolling horizontally
  vim.opt.sidescroll = 1      -- Scroll horizontally one column at a time
  
  -- Add autocmd to help with terminal clipboard integration
  vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
      if vim.v.event.operator == "y" and vim.v.event.regname == "+" then
        vim.fn.system("pbcopy", vim.fn.getreg("+"))
      end
    end,
    group = vim.api.nvim_create_augroup("CustomClipboard", { clear = true }),
    desc = "Ensure yanked text goes to system clipboard",
  })
end

-- Enable automatic reload of files changed outside of Neovim
vim.opt.autoread = true

-- Enable loading of local project configuration files
vim.opt.exrc = true
-- Trigger autoread when files change on disk
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "if mode() != 'c' | checktime | endif",
})

-- Auto-detect and set theme based on GNOME dark mode or terminal background
-- Delay this to run after LazyVim loads
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    require("config.theme-auto").set_theme_auto()
  end,
  desc = "Auto-detect theme after LazyVim loads"
})

-- Auto-create predictable socket based on tmux pane
-- This allows Cora to connect to any Neovim instance
local tmux_pane = vim.env.TMUX_PANE

if tmux_pane and tmux_pane ~= "" then
  -- We're in tmux, create a socket based on pane ID
  -- Remove the % prefix from the pane ID
  local pane_id = tmux_pane:gsub("%%", "")
  local socket_path = "/tmp/nvim-tmux-pane-" .. pane_id
  
  -- Only create socket if not already listening
  if vim.v.servername == "" or not vim.v.servername:match("^/tmp/nvim") then
    vim.fn.serverstart(socket_path)
    -- Notify on startup (delayed to avoid interfering with startup)
    vim.defer_fn(function()
      vim.notify("Neovim socket: " .. socket_path, vim.log.levels.INFO)
    end, 1000)
  end
else
  -- Not in tmux, create a default socket if needed
  if vim.v.servername == "" then
    -- Use PID for uniqueness outside tmux
    local socket_path = "/tmp/nvim-pid-" .. vim.fn.getpid()
    vim.fn.serverstart(socket_path)
    vim.defer_fn(function()
      vim.notify("Neovim socket: " .. socket_path, vim.log.levels.INFO)
    end, 1000)
  end
end

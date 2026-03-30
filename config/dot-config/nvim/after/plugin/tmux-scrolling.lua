-- Fix jumpy scrolling in tmux
-- This addresses the issue where scrolling in Neovim within tmux is not smooth

-- Only apply these settings when running inside tmux
if vim.env.TMUX then
  -- Map mouse wheel to smooth scrolling commands
  -- These mappings override the default behavior with smoother alternatives
  vim.keymap.set({"n", "v", "i"}, "<ScrollWheelUp>", "<C-Y>", { silent = true })
  vim.keymap.set({"n", "v", "i"}, "<ScrollWheelDown>", "<C-E>", { silent = true })

  -- For faster scrolling with Shift held
  vim.keymap.set({"n", "v", "i"}, "<S-ScrollWheelUp>", "5<C-Y>", { silent = true })
  vim.keymap.set({"n", "v", "i"}, "<S-ScrollWheelDown>", "5<C-E>", { silent = true })

  -- Reduce the scroll distance for finer control
  vim.opt.mousescroll = "ver:1,hor:1"
end
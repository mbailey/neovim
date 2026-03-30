-- Disable noice cmdline popup (causes issues with terminal buffers)
return {
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        view = "cmdline", -- use classic bottom cmdline instead of popup
      },
    },
  },
}

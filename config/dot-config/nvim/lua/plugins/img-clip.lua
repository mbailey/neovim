return {
  "dfendr/clipboard-image.nvim",
  ft = { "markdown" },
  config = function()
    require("clipboard-image").setup({
      default = {
        img_dir = "images",
        img_name = function() return os.date("%Y%m%d%H%M%S") end,
        img_dir_txt = "images",
      },
      markdown = {
        img_dir = "images",
        img_name = function() return os.date("%Y%m%d%H%M%S") end,
        img_dir_txt = "images",
      },
    })
  end,
  keys = {
    { "<leader>pi", "<cmd>PasteImg<cr>", desc = "Paste image from system clipboard" },
  },
}

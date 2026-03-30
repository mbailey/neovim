return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-mini/mini.icons",
  },
  config = function()
    require("render-markdown").setup({
      latex = { enabled = false },
    })
  end,
}

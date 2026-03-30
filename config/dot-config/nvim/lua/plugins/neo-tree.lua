return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_gitignored = false,
        },
      },
    },
    keys = {
      {
        "<leader>fg",
        function()
          require("neo-tree.sources.filesystem").toggle_gitignored_files()
        end,
        desc = "Toggle Git Ignored Files",
      },
    },
  },
}

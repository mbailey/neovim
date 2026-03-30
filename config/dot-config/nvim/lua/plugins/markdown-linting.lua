return {
  -- Configure markdown linting
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- Add markdownlint to ensure_installed if not already there
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "markdownlint")
    end,
  },

  -- Configure markdownlint to ignore line length for URLs
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        markdown = { "markdownlint" },
      },
      linters = {
        markdownlint = {
          args = {
            "--config",
            vim.fn.expand("~/.config/nvim/markdownlint.json"),
          },
        },
      },
    },
  },
}

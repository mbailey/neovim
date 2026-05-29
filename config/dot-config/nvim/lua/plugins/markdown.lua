return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      -- Add filetype-specific configuration
      local original_enabled = opts.enabled

      -- Set the enabled function
      opts.enabled = function()
        -- Disable completion in markdown files
        if vim.bo.filetype == "markdown" then
          return false
        end

        -- Otherwise use the original enabled function if it exists
        if type(original_enabled) == "function" then
          return original_enabled()
        end

        -- Default fallback
        return true
      end
    end,
  },
  
  -- Add markdown-specific settings
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "markdown", "markdown_inline" })
      end
    end,
  },

  -- Disable marksman LSP (enabled by lazyvim.plugins.extras.lang.markdown).
  -- It indexes Mike's entire markdown tree and eats gigabytes of RAM.
  -- See: 2026-05-29 -- killed marksman, removed Mason package.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = false,
      },
    },
  },

  -- Stop Mason from auto-installing marksman via LazyVim's markdown extra.
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      for i = #opts.ensure_installed, 1, -1 do
        if opts.ensure_installed[i] == "marksman" then
          table.remove(opts.ensure_installed, i)
        end
      end
    end,
  },
}

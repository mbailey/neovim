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
}

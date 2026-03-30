return {
  -- Enhance path completion in markdown files
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-path",
    },
    opts = function(_, opts)
      local cmp = require("cmp")
      
      -- Only modify path source for markdown files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          -- Get the current sources
          local sources = vim.tbl_deep_extend("force", {}, opts.sources or {})
          
          -- Find and replace the path source with our custom configuration
          for i, source in ipairs(sources) do
            if source.name == "path" then
              sources[i] = {
                name = "path",
                option = {
                  -- Enable symlink following
                  trailing_slash = true,
                  -- Resolve symlinks when getting completion items
                  get_cwd = function()
                    return vim.fn.resolve(vim.fn.getcwd())
                  end
                }
              }
              break
            end
          end
          
          -- Apply the modified sources to the current buffer
          cmp.setup.buffer({ sources = sources })
        end
      })
    end,
  },
}

return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      markdown = { "prettier" }, -- Use prettier for markdown formatting
    },
    formatters = {
      prettier = {
        -- Configure prettier to preserve existing line wrapping
        -- This prevents automatic wrapping of long lines including URLs
        prepend_args = { 
          "--prose-wrap", "preserve",
          "--print-width", "9999"  -- Set very large print width to avoid wrapping
        },
      },
    },
  },
}

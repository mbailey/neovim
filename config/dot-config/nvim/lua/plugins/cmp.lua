return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local cmp = require("cmp")
    opts.mapping = opts.mapping or {}

    opts.mapping["<CR>"] = function(fallback)
      fallback() -- Makes Enter always insert a newline
    end

    opts.mapping["<Tab>"] = cmp.mapping.confirm({ select = true }) -- Use Tab to accept
  end,
}

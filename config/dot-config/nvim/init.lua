-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Enable tabs on TSV files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tsv",
  callback = function()
    vim.opt_local.expandtab = false -- Use real tab characters
    vim.opt_local.tabstop = 8 -- Set tab width to 8
    vim.opt_local.shiftwidth = 8 -- Indentation uses 8 spaces
    vim.opt_local.softtabstop = 8 -- Keeps backspacing consistent
  end,
})

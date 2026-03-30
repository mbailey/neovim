-- vim-tidal plugin for TidalCycles live coding
return {
  "tidalcycles/vim-tidal",
  ft = { "tidal" }, -- Load only for .tidal files
  config = function()
    -- Use native terminal instead of tmux
    vim.g.tidal_target = "terminal"

    -- Set default keybindings
    -- <leader>e evaluates current line
    -- <leader>E evaluates multiple lines
    -- <leader>r runs the block above cursor
    -- <leader>h hush (stop all sounds)

    -- Optional: customize boot location if needed
    -- vim.g.tidal_boot = "~/.ghcup/bin/ghci"
  end,
}

-- mkdnflow.nvim - Fluent markdown navigation
-- Supports anchor links to headings within documents
return {
  "jakewvincent/mkdnflow.nvim",
  ft = "markdown", -- Only load for markdown files
  config = function()
    require("mkdnflow").setup({
      -- Create missing directories when following links
      create_dirs = true,
      -- Follow anchor links to headings
      perspective = {
        priority = "root", -- Use workspace root as base for relative paths
        fallback = "current",
      },
      -- Enable markdown link following with Enter key
      mappings = {
        MkdnEnter = { { "n", "v" }, "<CR>" }, -- Follow link with Enter
        MkdnGoBack = { "n", "<BS>" }, -- Go back with Backspace
        MkdnGoForward = { "n", "<Del>" }, -- Go forward with Delete
        MkdnFollowLink = { "n", "gf" }, -- Follow link with gf (our desired behavior!)
        MkdnDestroyLink = false, -- Disable destroy link (we don't need it)
        MkdnMoveSource = false, -- Disable move source
        MkdnYankAnchorLink = false, -- Disable yank anchor
        MkdnYankFileAnchorLink = false, -- Disable yank file anchor
        MkdnIncreaseHeading = false, -- Disable increase heading
        MkdnDecreaseHeading = false, -- Disable decrease heading
        MkdnToggleToDo = false, -- Disable toggle todo
        MkdnNewListItem = false, -- Disable new list item
        MkdnExtendList = false, -- Disable extend list
        MkdnUpdateNumbering = false, -- Disable update numbering
        MkdnTableNextCell = false, -- Disable table navigation
        MkdnTablePrevCell = false,
        MkdnTableNextRow = false,
        MkdnTablePrevRow = false,
        MkdnTableNewRowBelow = false,
        MkdnTableNewRowAbove = false,
        MkdnTableNewColAfter = false,
        MkdnTableNewColBefore = false,
        MkdnFoldSection = false, -- Disable folding
        MkdnUnfoldSection = false,
      },
      links = {
        -- Transform wiki links to markdown links
        style = "markdown",
        -- How to interpret links
        implicit_extension = "md",
        -- Transform links with spaces
        transform_explicit = false,
      },
    })
  end,
}

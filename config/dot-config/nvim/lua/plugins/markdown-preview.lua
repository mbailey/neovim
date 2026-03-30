return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreview", "MarkdownPreviewStop" },
  build = function()
    vim.fn["mkdp#util#install"]()
  end,
  ft = { "markdown" },
  init = function()
    -- Open the preview window after entering a markdown buffer
    vim.g.mkdp_auto_start = 0
    -- Auto close the preview window when changing to another buffer
    vim.g.mkdp_auto_close = 1
    -- Refresh markdown when saving the buffer or leaving insert mode
    vim.g.mkdp_refresh_slow = 0
    -- Use the browser specified in g:mkdp_browser
    vim.g.mkdp_browser = ""
    -- Allow preview page to be navigated with keyboard
    vim.g.mkdp_preview_options = {
      disable_sync_scroll = 0,
      sync_scroll_type = "middle",
      hide_yaml_meta = 1,
      disable_filename = 0,
    }
    -- Use a custom markdown style
    vim.g.mkdp_markdown_css = ""
    -- Use a custom highlight style
    vim.g.mkdp_highlight_css = ""
    -- Use a custom port
    vim.g.mkdp_port = ""
    -- Preview page title format
    vim.g.mkdp_page_title = "${name}"
    -- Recognized filetypes
    vim.g.mkdp_filetypes = { "markdown" }
    -- Echo preview page URL in command line when opening preview page
    vim.g.mkdp_echo_preview_url = 0
  end,
  keys = {
    { "<leader>mp", "<cmd>MarkdownPreview<cr>", desc = "Markdown Preview" },
    { "<leader>ms", "<cmd>MarkdownPreviewStop<cr>", desc = "Markdown Preview Stop" },
    { "<leader>mt", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview Toggle" },
  },
}

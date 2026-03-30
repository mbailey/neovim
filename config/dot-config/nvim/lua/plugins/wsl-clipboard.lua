return {
  "nvim-lua/plenary.nvim",
  event = "VeryLazy",
  config = function()
    -- Only apply these settings in WSL
    if vim.fn.has("wsl") == 1 then
      -- Function to copy visual selection to system clipboard
      local function copy_visual_selection()
        vim.cmd([[normal! "+y]])
        vim.notify("Copied selection to clipboard", vim.log.levels.INFO)
      end

      -- Function to copy current line to system clipboard
      local function copy_current_line()
        vim.cmd([[normal! "+yy]])
        vim.notify("Copied line to clipboard", vim.log.levels.INFO)
      end

      -- Function to paste from system clipboard
      local function paste_from_clipboard()
        vim.cmd([[normal! "+p]])
      end

      -- Create commands
      vim.api.nvim_create_user_command("WSLCopyLine", copy_current_line, {})
      vim.api.nvim_create_user_command("WSLCopySelection", copy_visual_selection, { range = true })
      vim.api.nvim_create_user_command("WSLPaste", paste_from_clipboard, {})

      -- Set up keymaps
      -- Visual mode: Y to copy selection to clipboard
      vim.keymap.set("v", "Y", copy_visual_selection, { desc = "Copy selection to system clipboard" })
      
      -- Normal mode: Y to copy current line to clipboard (similar to yy but to system clipboard)
      vim.keymap.set("n", "Y", copy_current_line, { desc = "Copy line to system clipboard" })
      
      -- Normal mode: Ctrl+V to paste from system clipboard
      vim.keymap.set({"n", "i"}, "<C-v>", paste_from_clipboard, { desc = "Paste from system clipboard" })
    end
  end,
}

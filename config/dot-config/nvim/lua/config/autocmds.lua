-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable line wrapping for markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Disable line wrapping for markdown files
    vim.opt_local.wrap = true
    -- Ensure horizontal scrolling works properly
    vim.opt_local.sidescrolloff = 8
    -- Make horizontal scrolling smoother
    vim.opt_local.sidescroll = 1

    -- Make gf work with Markdown links
    -- Set path to include the directory of the current file
    vim.opt_local.path:prepend(vim.fn.expand("%:p:h"))

    -- Transform Markdown links [text](path) to just path for gf command
    vim.opt_local.includeexpr = "substitute(v:fname, '\\[\\(.*\\)\\](\\(.*\\))', '\\2', '')"

    -- Allow following links even when file doesn't exist yet
    vim.opt_local.suffixesadd:append(".md")
  end,
})

-- Register JSON treesitter parser for JSONL files (syntax highlighting, folding, textobjects)
vim.treesitter.language.register("json", "jsonl")

-- JSONL file support: wrapping, pretty-print, type annotations
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.jsonl",
  callback = function()
    vim.opt_local.wrap = true

    -- Pretty-print current line with jq in a horizontal split
    vim.keymap.set("n", "<leader>jp", function()
      local line = vim.api.nvim_get_current_line()
      if line == "" then return end
      local result = vim.fn.system("jq '.'", line)
      if vim.v.shell_error ~= 0 then
        vim.notify("Invalid JSON on this line", vim.log.levels.WARN)
        return
      end
      vim.cmd("new")
      vim.bo.buftype = "nofile"
      vim.bo.bufhidden = "wipe"
      vim.bo.filetype = "json"
      local buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, "\n"))
    end, { buffer = true, desc = "Pretty-print current JSONL line" })

    -- Show the 'type' field of each line as virtual text (overview mode)
    vim.keymap.set("n", "<leader>jt", function()
      local ns = vim.api.nvim_create_namespace("jsonl_type_preview")
      vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      for i, l in ipairs(lines) do
        local t = l:match('"type"%s*:%s*"([^"]+)"')
        if t then
          vim.api.nvim_buf_set_extmark(0, ns, i - 1, 0, {
            virt_text = { { "  [" .. t .. "]", "Comment" } },
            virt_text_pos = "eol",
          })
        end
      end
      vim.notify("Type annotations added", vim.log.levels.INFO)
    end, { buffer = true, desc = "Show JSONL type annotations" })
  end,
})

-- Create a command to strip carriage returns
vim.api.nvim_create_user_command("StripCR", function()
  vim.cmd([[silent! %s/\r//g]])
  vim.notify("Carriage returns removed", vim.log.levels.INFO)
end, {})

-- :DiffOrig -- show diff between the current buffer (in-memory) and the file on disk.
-- Useful when nvim asks "save changes to X?" and you want to see what changed
-- before deciding. Standard recipe from :h DiffOrig (not installed by default).
--
-- Usage: when prompted "save changes?", press `c` (cancel), then run `:DiffOrig`.
-- Decide with `:wq` (save) or `:q!` (discard). Close the diff split with `<C-w>q`
-- in the scratch buffer.
vim.api.nvim_create_user_command("DiffOrig", function()
  vim.cmd("vert new")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.cmd("read ++edit #")
  vim.cmd("0d_")
  vim.cmd("diffthis")
  vim.cmd("wincmd p")
  vim.cmd("diffthis")
end, { desc = "Diff buffer against on-disk version" })

-- Keymap: <leader>do -- run DiffOrig with one keystroke.
vim.keymap.set("n", "<leader>do", "<cmd>DiffOrig<cr>", { desc = "Diff buffer vs disk (DiffOrig)" })

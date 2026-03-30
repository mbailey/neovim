return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      {
        "<leader>ml",
        function()
          local telescope = require("telescope.builtin")
          telescope.find_files({
            attach_mappings = function(_, map)
              map("i", "<CR>", function(prompt_bufnr)
                local selection = require("telescope.actions.state").get_selected_entry(prompt_bufnr)
                require("telescope.actions").close(prompt_bufnr)
                if selection then
                  -- Get the file path and name
                  local file_path = selection.value
                  local file_name = vim.fn.fnamemodify(file_path, ":t:r")

                  -- Create relative path from current file
                  local current_dir = vim.fn.expand("%:p:h")
                  local relative_path = vim.fn.fnamemodify(file_path, ":.")

                  -- Create the markdown link
                  local link_text = "[" .. file_name .. "](" .. relative_path .. ")"

                  -- Insert the link at cursor position
                  local pos = vim.api.nvim_win_get_cursor(0)
                  local line = vim.api.nvim_get_current_line()
                  local new_line = line:sub(1, pos[2]) .. link_text .. line:sub(pos[2] + 1)
                  vim.api.nvim_set_current_line(new_line)

                  -- Move cursor after the inserted link
                  vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + #link_text })
                end
              end)
              return true
            end,
          })
        end,
        desc = "Create Markdown link",
        ft = "markdown",
      },
    },
  },
}

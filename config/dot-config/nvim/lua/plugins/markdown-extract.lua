return {
  "nvim-lua/plenary.nvim",
  dependencies = {},
  config = function()
    -- Function to extract selected text to a new file and replace with a markdown link
    local function extract_to_file()
      -- Get the visual selection
      local start_pos = vim.fn.getpos("'<")
      local end_pos = vim.fn.getpos("'>")
      local start_line, start_col = start_pos[2], start_pos[3]
      local end_line, end_col = end_pos[2], end_pos[3]
      
      -- Get the selected text
      local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      if #lines == 0 then return end
      
      -- Adjust the first and last line to only include the selected text
      if #lines == 1 then
        lines[1] = string.sub(lines[1], start_col, end_col)
      else
        lines[1] = string.sub(lines[1], start_col)
        lines[#lines] = string.sub(lines[#lines], 1, end_col)
      end
      
      -- Get the current file's directory
      local current_dir = vim.fn.expand("%:p:h")
      
      -- Prompt for the file path
      local target_path = vim.fn.input({
        prompt = "Extract to path: ",
        default = current_dir .. "/",
        completion = "file"
      })
      
      if target_path == "" then
        vim.notify("Extraction cancelled", vim.log.levels.INFO)
        return
      end
      
      -- Prompt for the file name (without extension)
      local file_name = vim.fn.input({
        prompt = "Extract to filename (without extension): ",
        default = "",
        completion = "file"
      })
      
      if file_name == "" then
        vim.notify("Extraction cancelled", vim.log.levels.INFO)
        return
      end
      
      -- Add .md extension if not provided
      if not file_name:match("%.%w+$") then
        file_name = file_name .. ".md"
      end
      
      -- Combine path and filename
      local full_path = target_path
      if not full_path:match("/$") then
        full_path = full_path .. "/"
      end
      full_path = full_path .. file_name
      
      -- Create directory if it doesn't exist
      local dir = vim.fn.fnamemodify(full_path, ":h")
      if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
      end
      
      -- Write the selected text to the new file
      local file = io.open(full_path, "w")
      if not file then
        vim.notify("Failed to create file: " .. full_path, vim.log.levels.ERROR)
        return
      end
      
      file:write(table.concat(lines, "\n"))
      file:close()
      
      -- Create a relative path for the link
      local rel_path = vim.fn.fnamemodify(full_path, ":.")
      local display_name = vim.fn.fnamemodify(file_name, ":r")
      
      -- Create the markdown link
      local link = "[" .. display_name .. "](" .. rel_path .. ")"
      
      -- Replace the selected text with the link
      vim.api.nvim_buf_set_text(0, start_line - 1, start_col - 1, end_line - 1, end_col, {link})
      
      -- Notify the user
      vim.notify("Extracted text to " .. full_path, vim.log.levels.INFO)
    end
    
    -- Create a command for extracting text
    vim.api.nvim_create_user_command("ExtractToFile", function()
      extract_to_file()
    end, { range = true })
    
    -- Add keybinding for markdown files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.keymap.set("v", "<leader>me", function()
          extract_to_file()
        end, { buffer = true, desc = "Extract selection to file" })
      end
    })
  end,
}

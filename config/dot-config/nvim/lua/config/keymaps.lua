-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Toggle between light and dark themes
vim.keymap.set("n", "<leader>tt", function()
  if vim.o.background == "dark" then
    vim.o.background = "light"
    vim.notify("Switched to light theme (day)", vim.log.levels.INFO)
  else
    vim.o.background = "dark"
    vim.notify("Switched to dark theme (night)", vim.log.levels.INFO)
  end
end, { desc = "Toggle between light and dark themes" })

-- Refresh theme from system settings
vim.keymap.set("n", "<leader>tr", function()
  require("config.theme-auto").set_theme_auto()
  vim.notify("Theme refreshed from system settings", vim.log.levels.INFO)
end, { desc = "Refresh theme from system settings" })

-- Add markdown-specific keybindings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Play audio file from markdown link on current line
    -- Extracts path from [text](./path.wav) or [text](path.mp3) format
    vim.keymap.set("n", "<leader>ma", function()
      local line = vim.api.nvim_get_current_line()
      -- Match markdown link with audio extension
      local path = line:match("%[.-%]%((.-%.[wW][aA][vV])%)")
                or line:match("%[.-%]%((.-%.[mM][pP]3)%)")
                or line:match("%[.-%]%((.-%.[fF][lL][aA][cC])%)")
                or line:match("%[.-%]%((.-%.[oO][gG][gG])%)")
                or line:match("%[.-%]%((.-%.[mM]4[aA])%)")

      if not path then
        vim.notify("No audio link found on this line", vim.log.levels.WARN)
        return
      end

      -- Resolve relative paths
      if path:match("^%./") or not path:match("^/") then
        local current_dir = vim.fn.expand("%:p:h")
        path = current_dir .. "/" .. path:gsub("^%./", "")
      end

      -- Expand ~ to home directory
      path = path:gsub("^~", vim.fn.expand("$HOME"))

      -- Check file exists
      if vim.fn.filereadable(path) == 0 then
        vim.notify("Audio file not found: " .. path, vim.log.levels.ERROR)
        return
      end

      -- Play with mpv in background (mixes with any existing audio)
      vim.fn.jobstart({"mpv", "--no-video", path}, {detach = true})
      vim.notify("Playing: " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
    end, { buffer = true, desc = "Play audio from markdown link" })

    -- Add keymap to copy code block line
    vim.keymap.set("n", "<leader>cy", function()
      -- Get current line
      local line = vim.api.nvim_get_current_line()
      -- Copy to system clipboard
      vim.fn.setreg("+", line)
      vim.notify("Copied line to clipboard", vim.log.levels.INFO)
    end, { buffer = true, desc = "Copy current line to clipboard" })
    
    -- Override gx for audio/video files to use mpv instead of system default
    vim.keymap.set("n", "gx", function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]

      -- Check if cursor is on a markdown link
      local link_pattern = "%[.-%]%((.-)%)"
      local path = nil

      -- Find links on current line and check if cursor is within one
      for match_start, match_path, match_end in line:gmatch("()%[.-%]%((.-)%)()") do
        if col >= match_start - 1 and col < match_end - 1 then
          path = match_path
          break
        end
      end

      -- If no link found at cursor, try to get path from whole line (fallback)
      if not path then
        path = line:match(link_pattern)
      end

      -- If still no path, fall back to default gx behavior
      if not path then
        vim.cmd("normal! gx")
        return
      end

      -- Check if it's an audio/video file
      local audio_exts = { "wav", "mp3", "flac", "ogg", "m4a", "aac", "opus" }
      local video_exts = { "mp4", "mkv", "avi", "mov", "webm", "m4v" }
      local ext = path:match("%.([^.]+)$")
      if ext then ext = ext:lower() end

      local is_media = false
      if ext then
        for _, e in ipairs(audio_exts) do
          if ext == e then is_media = true; break end
        end
        if not is_media then
          for _, e in ipairs(video_exts) do
            if ext == e then is_media = true; break end
          end
        end
      end

      -- For non-media files, use default behavior
      if not is_media then
        -- If it's a URL, open in browser
        if path:match("^https?://") then
          vim.fn.jobstart({"open", path}, {detach = true})
        else
          vim.cmd("normal! gx")
        end
        return
      end

      -- Resolve relative paths for media files
      if path:match("^%./") or not path:match("^[/~]") and not path:match("^https?://") then
        local current_dir = vim.fn.expand("%:p:h")
        path = current_dir .. "/" .. path:gsub("^%./", "")
      end

      -- Expand ~ to home directory
      path = path:gsub("^~", vim.fn.expand("$HOME"))

      -- Check file exists (for local files)
      if not path:match("^https?://") and vim.fn.filereadable(path) == 0 then
        vim.notify("Media file not found: " .. path, vim.log.levels.ERROR)
        return
      end

      -- Play with mpv
      vim.fn.jobstart({"mpv", "--no-video", path}, {detach = true})
      vim.notify("Playing: " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
    end, { buffer = true, desc = "Open link (mpv for media)" })

    vim.keymap.set("n", "<leader>ml", function()
      local telescope_ok, telescope = pcall(require, "telescope.builtin")
      if not telescope_ok then
        vim.notify("Telescope not available", vim.log.levels.ERROR)
        return
      end

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
    end, { buffer = true, desc = "Create Markdown link" })
  end,
})

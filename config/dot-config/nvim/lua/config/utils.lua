-- Utility functions for Neovim configuration

local M = {}

-- Function to navigate to a Markdown link under the cursor
function M.goto_markdown_link()
  -- Get the line under the cursor
  local line = vim.api.nvim_get_current_line()
  -- Get cursor position
  local col = vim.api.nvim_win_get_cursor(0)[2]

  -- Find all markdown links in the line
  local links = {}
  for link_text, link_target in line:gmatch("%[([^%]]+)%]%(([^%)]+)%)") do
    local start_idx = line:find("%[" .. link_text .. "%]%(" .. link_target .. "%)", 1, true)
    if start_idx then
      local finish_idx = start_idx + #link_text + #link_target + 4 -- [text](target) = text + target + 4 chars
      table.insert(links, {
        start = start_idx,
        finish = finish_idx,
        text = link_text,
        target = link_target,
      })
    end
  end

  -- Debug info
  vim.notify("Found " .. #links .. " links in line", vim.log.levels.INFO)
  for i, link in ipairs(links) do
    vim.notify("Link " .. i .. ": " .. link.text .. " -> " .. link.target, vim.log.levels.INFO)
  end

  -- If there's only one link on the line, use it regardless of cursor position
  local link_target = nil
  if #links == 1 then
    link_target = links[1].target
    vim.notify("Using single link: " .. link_target, vim.log.levels.INFO)
  else
    -- If there are multiple links, find the one under the cursor
    for _, link in ipairs(links) do
      if col >= link.start - 1 and col < link.finish then
        link_target = link.target
        vim.notify("Using link under cursor: " .. link_target, vim.log.levels.INFO)
        break
      end
    end

    -- If no link was found under cursor but there are links on the line,
    -- try to find the closest link to the cursor
    if link_target == nil and #links > 0 then
      local closest_link = nil
      local min_distance = math.huge

      for _, link in ipairs(links) do
        local link_center = (link.start + link.finish) / 2
        local distance = math.abs(col - link_center)

        if distance < min_distance then
          min_distance = distance
          closest_link = link
        end
      end

      if closest_link then
        link_target = closest_link.target
        vim.notify("Using closest link: " .. link_target, vim.log.levels.INFO)
      end
    end
  end

  -- If we found a link
  if link_target then
    -- Remove any anchor part from the link (#section)
    link_target = link_target:gsub("#.*$", "")

    -- Get the directory of the current file
    local current_dir = vim.fn.expand("%:p:h")

    -- Resolve the path relative to the current file
    local full_path

    -- Debug information
    vim.notify("Link target: " .. link_target, vim.log.levels.INFO)
    vim.notify("Current directory: " .. current_dir, vim.log.levels.INFO)

    -- Check if it's an absolute path
    if vim.fn.has("win32") == 1 and link_target:match("^%a:[\\/]") or link_target:match("^/") then
      full_path = link_target
    -- Check if readable as-is (relative to CWD)
    elseif vim.fn.filereadable(link_target) == 1 then
      full_path = link_target
    else
      -- Path relative to current file
      full_path = current_dir .. "/" .. link_target
    end

    -- Debug the resolved path
    vim.notify("Resolved path: " .. full_path, vim.log.levels.INFO)

    -- Try multiple path variations
    local paths_to_try = {
      full_path, -- Try the exact path first
      full_path .. ".md", -- Try with .md extension
      vim.fn.expand("%:p:h") .. "/" .. link_target, -- Try relative to current file
      vim.fn.expand("%:p:h") .. "/" .. link_target .. ".md", -- Relative with .md
      vim.fn.getcwd() .. "/" .. link_target, -- Try relative to working directory
      vim.fn.getcwd() .. "/" .. link_target .. ".md", -- Working dir with .md
    }

    -- Debug all paths we're trying
    vim.notify("Trying paths:", vim.log.levels.INFO)
    for i, path in ipairs(paths_to_try) do
      vim.notify(
        i .. ": " .. path .. " (exists: " .. tostring(vim.fn.filereadable(path) == 1) .. ")",
        vim.log.levels.INFO
      )
    end

    -- Try each path
    local found = false
    for _, path in ipairs(paths_to_try) do
      if vim.fn.filereadable(path) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(path))
        found = true
        break
      end
    end

    -- If not found, offer to create the file
    if not found then
      -- Notify user and offer to create the file
      local create_file = vim.fn.confirm("File not found: " .. link_target .. "\nCreate it?", "&Yes\n&No", 1)
      if create_file == 1 then
        -- Create the directory if it doesn't exist
        local dir = vim.fn.fnamemodify(full_path, ":h")
        if vim.fn.isdirectory(dir) == 0 then
          vim.fn.mkdir(dir, "p")
        end

        -- Determine if we should add .md extension
        local file_to_create = full_path
        if not full_path:match("%.%w+$") then
          file_to_create = full_path .. ".md"
        end

        -- Create and edit the file
        vim.cmd("edit " .. vim.fn.fnameescape(file_to_create))
      end
    end
  else
    -- If no markdown link found on the line, try to extract a path from the line
    local possible_path = line:match("([%w%p]+%.%w+)")
    if possible_path and vim.fn.filereadable(possible_path) == 1 then
      vim.cmd("edit " .. vim.fn.fnameescape(possible_path))
      vim.notify("Opening file: " .. possible_path, vim.log.levels.INFO)
    else
      -- Fall back to standard gf behavior
      local ok = pcall(function()
        vim.cmd("normal! gf")
      end)
      if not ok then
        vim.notify("Could not find file under cursor", vim.log.levels.WARN)
      end
    end
  end
end

return M

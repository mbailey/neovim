---
name: neovim
description: Neovim remote control and socket management for tmux environments. Use this skill when you need to control Neovim instances from agents, open files in existing editor sessions, navigate to specific lines, search for patterns, or get editor status without direct terminal access.
---

# Neovim Remote Control Skill

Remote control of Neovim instances running in tmux panes via socket-based communication.

## Purpose

This skill provides AI agents with the ability to:
- Discover and connect to Neovim instances in tmux panes
- Open files at specific lines in running editor sessions
- Navigate within files and search for patterns
- Query editor status (current file, cursor position, mode)
- Control Neovim without Python dependencies (pure bash)

## When to Use This Skill

Use this skill when:
- Opening files in a user's existing Neovim session
- Navigating to specific lines for code review or debugging
- Searching for patterns across files
- Checking what file the user is currently editing
- Working in a tmux environment with multiple Neovim instances
- You need to interact with Neovim but don't have direct terminal access

## Core Concepts

### Socket-Based Communication

Neovim instances expose sockets for remote control when started with `--listen`:
- Socket naming: `/tmp/nvim-tmux-pane-{PANE_ID}`
- Pane ID is the tmux pane number (without `%` prefix)
- Multiple Neovim instances can run simultaneously with unique sockets

### Auto-Detection Priority

When no socket is specified, `nvim-socket auto` selects based on:
1. **Current pane**: Socket in the tmux pane where command runs
2. **Same window**: Socket in same tmux window as current pane
3. **Same directory**: Socket with matching working directory
4. **Any available**: First valid socket found

## Tools and Commands

### Socket Discovery: `nvim-socket`

Discover and manage Neovim sockets in tmux environments.

#### List all sockets with context

```bash
nvim-socket list
```

Output shows: pane ID, window, directory, command for each socket.

#### Find socket for specific pane

```bash
nvim-socket find           # Current pane
nvim-socket find 15        # Pane 15
```

Returns socket path or error if not found.

#### Show detailed context

```bash
nvim-socket show           # Current pane
nvim-socket show 28        # Pane 28
```

Shows: socket path, pane ID, window, directory, command, current file.

#### Auto-select best socket

```bash
nvim-socket auto
```

Returns socket path based on priority (current pane > same window > same dir > any).

### Remote Control: `nvim-remote`

Control Neovim instances via CLI commands (no Python/pynvim required).

#### Open file (with optional line number)

```bash
nvim-remote edit file.txt              # Open at first line
nvim-remote edit file.txt 42           # Open at line 42
nvim-remote edit /path/to/file.md 100  # Absolute path, line 100
```

Opens file in existing Neovim session. If line number specified, cursor moves to that line.

#### Jump to line in current file

```bash
nvim-remote goto 100        # Jump to line 100
nvim-remote goto 1          # Jump to first line
```

Moves cursor to specified line without changing files.

#### Search for pattern

```bash
nvim-remote search "TODO"           # Search for TODO
nvim-remote search "function.*init" # Regex search
nvim-remote search "error"          # Case-sensitive
```

Searches current buffer and highlights matches. Cursor moves to first match.

#### Get editor status

```bash
nvim-remote status
```

Returns: socket path, current file, cursor position, editor mode, modified status, filetype, total line count.

#### Specify socket explicitly

```bash
nvim-remote -s /tmp/nvim-tmux-pane-15 edit file.txt
nvim-remote --socket /tmp/nvim-tmux-pane-28 status
```

Override auto-detection with explicit socket path.

## Common Workflows

### Open file for user review

```bash
nvim-remote edit ~/project/src/main.py 45
```

Agent use case: Show user problematic code at exact line.

### Navigate to error location

```bash
nvim-remote goto 127
```

Agent use case: After analyzing logs, jump to error line.

### Search for TODOs or FIXMEs

```bash
nvim-remote search "TODO"
```

Agent use case: Help user find incomplete work.

### Check what user is working on

```bash
nvim-remote status
```

Agent use case: Understand context before making suggestions.

### Work with specific Neovim instance

```bash
nvim-socket list
nvim-remote -s /tmp/nvim-tmux-pane-28 edit notes.md
```

Agent use case: Multiple Neovim sessions, need specific one.

## Environment Variables

- `NVIM_SOCKET_PATH`: Default socket path for nvim-remote
- `NVIM_TEST_SOCKET`: Socket path for testing

## Best Practices for Agents

1. **Always verify socket exists** before sending commands:
   ```bash
   SOCKET=$(nvim-socket auto)
   if [[ $? -ne 0 ]]; then
     echo "No Neovim instance found"
     exit 1
   fi
   ```

2. **Check current file before editing** -- avoid disrupting user's work.

3. **Use absolute paths** when opening files:
   ```bash
   nvim-remote edit "$(realpath file.txt)"
   ```

4. **Provide feedback** -- confirm what happened after operations.

5. **Handle errors gracefully**:
   ```bash
   if ! nvim-remote edit missing.txt 2>/dev/null; then
     echo "Error: Could not open file"
     exit 1
   fi
   ```

## Related Tools

- `nvim-tmux` - Open file/directory in Neovim in new tmux window
- `nvim-install` - Install Neovim
- `nvim-clean-swapfiles` - Clean stale swap files

## References

For detailed technical documentation, see:

- [references/remote-control.md](references/remote-control.md) - Complete command reference with advanced usage, socket management, scripting examples, and troubleshooting
- [references/visual-selection.md](references/visual-selection.md) - Visual selection evaluation (CLI vs pynvim), all visual mode operations
- [references/shortcuts.md](references/shortcuts.md) - Neovim keyboard shortcuts quick reference
- [references/lsp-navigation.md](references/lsp-navigation.md) - LSP code navigation with LazyVim (go-to-definition, find references, code actions)

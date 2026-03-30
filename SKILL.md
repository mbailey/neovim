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

Returns:
- Socket path
- Current file path
- Cursor position (line, column)
- Editor mode (normal, insert, visual, etc.)
- Modified status (0 = saved, 1 = unsaved changes)
- Filetype
- Total line count

#### Specify socket explicitly

```bash
nvim-remote -s /tmp/nvim-tmux-pane-15 edit file.txt
nvim-remote --socket /tmp/nvim-tmux-pane-28 status
```

Override auto-detection with explicit socket path.

## Common Workflows

### Open file for user review

```bash
# Auto-detect socket and open file at specific line
nvim-remote edit ~/project/src/main.py 45
```

Agent use case: Show user problematic code at exact line.

### Navigate to error location

```bash
# Jump to line where error occurred
nvim-remote goto 127
```

Agent use case: After analyzing logs, jump to error line.

### Search for TODOs or FIXMEs

```bash
# Search for TODO comments
nvim-remote search "TODO"
```

Agent use case: Help user find incomplete work.

### Check what user is working on

```bash
# Get current file and position
nvim-remote status
```

Agent use case: Understand context before making suggestions.

### Work with specific Neovim instance

```bash
# Discover available instances
nvim-socket list

# Use specific pane's instance
nvim-remote -s /tmp/nvim-tmux-pane-28 edit notes.md
```

Agent use case: Multiple Neovim sessions, need specific one.

## Usage Examples

### Example 1: Open code at error line

```bash
# User reports error at line 156
SOCKET=$(nvim-socket auto)
nvim-remote -s "$SOCKET" edit /path/to/file.py 156
```

### Example 2: Check if file is already open

```bash
# Get current file
STATUS=$(nvim-remote status)
CURRENT_FILE=$(echo "$STATUS" | grep "^File:" | cut -d' ' -f2-)

if [[ "$CURRENT_FILE" == "/path/to/target.md" ]]; then
  echo "File already open"
else
  nvim-remote edit /path/to/target.md
fi
```

### Example 3: Search across multiple sessions

```bash
# List all Neovim instances
nvim-socket list

# Search in each instance (if needed)
for socket in /tmp/nvim-tmux-pane-*; do
  if [[ -S "$socket" ]]; then
    nvim-remote -s "$socket" search "FIXME"
  fi
done
```

## Environment Variables

- `NVIM_SOCKET_PATH`: Default socket path for nvim-remote
- `NVIM_TEST_SOCKET`: Socket path for testing

## Technical Details

### CLI vs Python Approach

This implementation uses `nvim --server` CLI commands instead of pynvim:
- ✅ No Python dependencies
- ✅ Pure bash scripts
- ✅ Simpler deployment
- ✅ Easier debugging
- ✅ Works with any Neovim version supporting `--server`

### CLI Commands Used

- `nvim --server <socket> --remote <file>` - Open file
- `nvim --server <socket> --remote-send <keys>` - Send keystrokes
- `nvim --server <socket> --remote-expr <expr>` - Evaluate expression

See `tests/CLI-TEST-RESULTS.md` for validation of all CLI alternatives.

## Best Practices for Agents

### 1. Always verify socket exists

```bash
SOCKET=$(nvim-socket auto)
if [[ $? -ne 0 ]]; then
  echo "No Neovim instance found"
  exit 1
fi
```

### 2. Check current file before editing

Avoid disrupting user's work by checking what's open first.

### 3. Use absolute paths

Always use absolute paths when opening files:
```bash
nvim-remote edit "$(realpath file.txt)"
```

### 4. Provide feedback to user

After operations, confirm what happened:
```bash
nvim-remote edit file.txt 42
echo "Opened file.txt at line 42 in Neovim"
```

### 5. Handle errors gracefully

```bash
if ! nvim-remote edit missing.txt 2>/dev/null; then
  echo "Error: Could not open file"
  exit 1
fi
```

## Troubleshooting

### No socket found

**Problem**: `nvim-socket auto` returns error

**Solutions**:
1. Verify Neovim is running with socket: `ls /tmp/nvim-*`
2. Check Neovim was started with `--listen` flag
3. List all sockets: `nvim-socket list`
4. Specify socket explicitly: `nvim-remote -s /path/to/socket`

### Socket exists but commands fail

**Problem**: Socket file exists but commands don't work

**Solutions**:
1. Verify socket is active: `nvim --server /tmp/nvim-pane-X --remote-expr "1"`
2. Check Neovim version supports `--server`: `nvim --version`
3. Socket might be stale (Neovim crashed) - remove and restart

### File opens but cursor not at correct line

**Problem**: `nvim-remote edit file.txt 100` opens file but cursor at line 1

**Solution**: This is expected behavior - file opens first, then cursor moves. There may be a brief delay. Use `nvim-remote goto` after opening if needed.

## Documentation References

For detailed information, see:
- `docs/` - Comprehensive Neovim documentation
- `tests/CLI-TEST-RESULTS.md` - CLI validation results
- `tests/test-cli-alternatives.sh` - Test suite

## Related Tools

- `nvim-tmux` - Open file/directory in Neovim in new tmux window
- `nvim-install` - Install Neovim
- `nvim-clean-swapfiles` - Clean stale swap files

## Integration with Other Skills

### With tmux skill

```bash
# Get current tmux pane
PANE=$(tmux display-message -p "#{pane_id}" | sed 's/^%//')

# Find Neovim socket in current pane
SOCKET=$(nvim-socket find "$PANE")

# Control that specific instance
nvim-remote -s "$SOCKET" edit file.txt
```

### With show-and-tell skill

The show-and-tell package provides visual context sharing between AI and users:

```bash
# Display file for user (uses nvim-remote under the hood)
show src/main.py:42           # Opens at line 42

# Observe what user is viewing (detects Neovim via socket)
look                          # Captures pane content, shows file/line if in Neovim
look -H                       # Show tmux hierarchy
```

Key integration points:
- `show file:line` uses nvim-remote to open files in existing Neovim
- `look` detects Neovim in panes and queries file/position via socket
- Both commands use the same socket naming convention (`/tmp/nvim-tmux-pane-*`)

See `mt package show show-and-tell` for details.

## Installation

This is a metool package:

```bash
mt package add dev/neovim
mt package install neovim
```

Scripts will be symlinked to `~/.metool/bin/` and available in PATH.

# Neovim Remote Control Reference

Comprehensive technical reference for controlling Neovim instances via socket-based communication in tmux environments.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [nvim-socket Command Reference](#nvim-socket-command-reference)
- [nvim-remote Command Reference](#nvim-remote-command-reference)
- [Socket Management](#socket-management)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)
- [Technical Details](#technical-details)

## Overview

The Neovim remote control system provides CLI-based remote control of Neovim instances without Python dependencies. It consists of two main tools:

1. **nvim-socket** - Socket discovery and management
2. **nvim-remote** - Remote control operations

Both tools use `nvim --server` CLI commands internally, eliminating the need for pynvim.

### Key Features

- ✅ Pure bash implementation (no Python/pynvim required)
- ✅ Socket auto-detection with intelligent priority
- ✅ Context-aware socket selection
- ✅ Full remote control capabilities
- ✅ Integration with tmux environments
- ✅ Support for multiple concurrent Neovim instances

## Architecture

### Socket Naming Convention

Sockets follow a standardized naming pattern:

```
/tmp/nvim-tmux-pane-{PANE_ID}
```

Where `{PANE_ID}` is the tmux pane number without the `%` prefix.

**Examples**:
- Pane `%15` → `/tmp/nvim-tmux-pane-15`
- Pane `%28` → `/tmp/nvim-tmux-pane-28`
- Pane `%0` → `/tmp/nvim-tmux-pane-0`

### Socket Lifecycle

1. **Creation**: Socket created when Neovim starts with `--listen` flag
2. **Active**: Socket available for remote control while Neovim runs
3. **Cleanup**: Socket removed when Neovim exits normally
4. **Stale**: Socket file may persist after Neovim crash (manual cleanup required)

### Auto-Detection Priority

When no socket is explicitly specified, selection follows this priority:

1. **Current Pane** - Socket in the tmux pane executing the command
2. **Same Window** - Socket in any pane within the same tmux window
3. **Same Directory** - Socket with matching working directory
4. **First Available** - Any valid socket found in `/tmp`

## nvim-socket Command Reference

Socket discovery and management tool.

### Global Options

```bash
nvim-socket [OPTIONS] <subcommand>
```

**Options**:
- `-h, --help` - Display help message and exit

### Subcommand: list

List all Neovim sockets with context information.

**Syntax**:
```bash
nvim-socket list
```

**Output Format**:
```
PANE       WINDOW   PATH                           COMMAND
----       ------   ----                           -------
28         13       ...ents-skill-and-project-docs nvim
34         15       ...ithub.com/mbailey/voicemode nvim
```

**Columns**:
- `PANE` - Tmux pane ID (numeric, without `%`)
- `WINDOW` - Tmux window index
- `PATH` - Current working directory (truncated to 30 chars)
- `COMMAND` - Running command (typically `nvim`)

**Exit Codes**:
- `0` - Success, sockets found
- `1` - No sockets found

**Notes**:
- Paths longer than 30 characters are truncated with `...` prefix
- Stale sockets (pane no longer exists) show `N/A` for context
- Only shows sockets matching `/tmp/nvim-tmux-pane-*` pattern

### Subcommand: find

Find socket for a specific tmux pane.

**Syntax**:
```bash
nvim-socket find [PANE_ID]
```

**Arguments**:
- `PANE_ID` (optional) - Tmux pane ID (with or without `%` prefix). Defaults to current pane.

**Examples**:
```bash
nvim-socket find           # Current pane
nvim-socket find 15        # Pane 15
nvim-socket find %28       # Pane 28 (% prefix optional)
```

**Output**:
```
/tmp/nvim-tmux-pane-15
```

**Exit Codes**:
- `0` - Socket found, path printed to stdout
- `1` - No socket found for specified pane

**Error Messages**:
```
No socket found for pane 15
```

### Subcommand: show

Show detailed context for a pane's Neovim instance.

**Syntax**:
```bash
nvim-socket show [PANE_ID]
```

**Arguments**:
- `PANE_ID` (optional) - Tmux pane ID. Defaults to current pane.

**Examples**:
```bash
nvim-socket show           # Current pane
nvim-socket show 28        # Pane 28
```

**Output**:
```
Socket: /tmp/nvim-tmux-pane-28
Pane ID: 28
Window: 13
Directory: /Users/admin/Code/project
Command: nvim
Current file: /Users/admin/Code/project/main.py
```

**Fields**:
- `Socket` - Full socket path
- `Pane ID` - Numeric pane ID
- `Window` - Window index
- `Directory` - Current working directory
- `Command` - Running command
- `Current file` - File open in Neovim (if `nvim` binary available)

**Exit Codes**:
- `0` - Success
- `1` - Socket not found or pane doesn't exist

**Dependencies**:
- Requires `nvim` binary in PATH to query current file
- Current file shows `(unable to query)` if `nvim` unavailable

### Subcommand: auto

Auto-select best socket based on priority.

**Syntax**:
```bash
nvim-socket auto
```

**Output**:
```
/tmp/nvim-tmux-pane-28
```

**Selection Priority**:
1. Socket in current tmux pane
2. Socket in same window as current pane
3. Socket with matching working directory
4. First valid socket found

**Exit Codes**:
- `0` - Socket found, path printed to stdout
- `1` - No valid sockets found

**Use Cases**:
- Scripts that need to find "best" socket without user input
- Integration with other tools requiring automatic socket selection
- Default socket for `nvim-remote` when no socket specified

## nvim-remote Command Reference

Remote control tool for Neovim instances.

### Global Options

```bash
nvim-remote [OPTIONS] <command> [ARGS...]
```

**Options**:
- `-s, --socket PATH` - Explicit socket path (overrides auto-detection)
- `-h, --help` - Display help message and exit

**Environment Variables**:
- `NVIM_SOCKET_PATH` - Default socket path if not specified
- `NVIM_TEST_SOCKET` - Socket path for testing (takes precedence)

**Socket Resolution Order**:
1. Command-line `--socket` argument
2. `NVIM_SOCKET_PATH` environment variable
3. Auto-detection via `nvim-socket auto`

### Command: edit

Open a file, optionally at a specific line.

**Syntax**:
```bash
nvim-remote edit <file> [line]
```

**Arguments**:
- `file` (required) - Path to file (relative or absolute)
- `line` (optional) - Line number to jump to after opening

**Examples**:
```bash
nvim-remote edit file.txt                    # Open file.txt
nvim-remote edit file.txt 42                 # Open at line 42
nvim-remote edit /path/to/file.py 100        # Absolute path
nvim-remote -s /tmp/nvim-pane-15 edit file.md 1  # Explicit socket
```

**Behavior**:
1. Opens file using `nvim --server <socket> --remote <file>`
2. If line number specified, sends `:LINE<CR>` command to jump
3. Converts relative paths to absolute paths automatically
4. File must exist (verified before opening)

**Output**:
```
Opened /absolute/path/to/file.txt at line 42
```

**Exit Codes**:
- `0` - File opened successfully
- `1` - File not found, socket invalid, or command failed

**Error Messages**:
```
Error: File not found: missing.txt
Error: Socket does not exist: /tmp/nvim-pane-99
```

**Notes**:
- File is opened in current window/buffer
- Previous file may be closed depending on Neovim settings
- Line number jump happens after file opens (brief delay possible)

### Command: goto

Jump to a line number in the current file.

**Syntax**:
```bash
nvim-remote goto <line>
```

**Arguments**:
- `line` (required) - Line number (positive integer)

**Examples**:
```bash
nvim-remote goto 100       # Jump to line 100
nvim-remote goto 1         # Jump to first line
nvim-remote goto 999999    # Jump to last line if < 999999
```

**Behavior**:
- Sends `:LINE<CR>` to Neovim
- Operates on currently open file
- Invalid line numbers handled by Neovim (jumps to last line)

**Output**:
```
Jumped to line 100
```

**Exit Codes**:
- `0` - Success
- `1` - Invalid line number or socket error

**Error Messages**:
```
Error: Line must be a number
```

**Notes**:
- Does not change files, only cursor position
- Cursor column resets to column 1
- Works in normal mode (switches from insert/visual if needed)

### Command: search

Search for a pattern in the current buffer.

**Syntax**:
```bash
nvim-remote search <pattern>
```

**Arguments**:
- `pattern` (required) - Search pattern (supports vim regex)

**Examples**:
```bash
nvim-remote search "TODO"                    # Find TODO
nvim-remote search "function.*init"          # Regex search
nvim-remote search "error\|warning"          # Multiple patterns
nvim-remote search "exact phrase"            # Multi-word search
```

**Behavior**:
- Sends `/<pattern><CR>` to Neovim
- Cursor moves to first match
- Search history updated
- Matches highlighted (if hlsearch enabled)

**Special Character Handling**:
- Forward slash `/` escaped automatically: `\/`
- Other special chars follow vim search syntax:
  - `.` = any character
  - `*` = zero or more
  - `\<` = word boundary start
  - `\>` = word boundary end

**Output**:
```
Searched for: TODO
```

**Exit Codes**:
- `0` - Search executed (doesn't indicate match found)
- `1` - Socket error

**Notes**:
- Empty pattern searches for last search
- Use `n` to jump to next match (in Neovim)
- Use `N` to jump to previous match (in Neovim)
- Pattern not found shows error in Neovim status line

### Command: status

Get comprehensive status of Neovim instance.

**Syntax**:
```bash
nvim-remote status
```

**Examples**:
```bash
nvim-remote status                           # Current socket
nvim-remote -s /tmp/nvim-pane-28 status     # Specific socket
```

**Output**:
```
Socket: /tmp/nvim-tmux-pane-28
File: /Users/admin/project/main.py
Position: line 42, column 15
Mode: n
Modified: 0
Filetype: python
Lines: 256
```

**Fields**:
- `Socket` - Socket path being queried
- `File` - Current file path (absolute) or `[No Name]`
- `Position` - Cursor line and column (1-indexed)
- `Mode` - Vim mode:
  - `n` = normal
  - `i` = insert
  - `v` = visual
  - `V` = visual line
  - `CTRL-V` = visual block
  - `c` = command-line
- `Modified` - Buffer modification status:
  - `0` = saved
  - `1` = unsaved changes
- `Filetype` - Detected filetype or `none`
- `Lines` - Total line count

**Exit Codes**:
- `0` - Success
- `1` - Socket error

**Use Cases**:
- Check user's current context before taking action
- Verify file is open before navigating
- Determine if changes need saving
- Get cursor position for relative navigation

**Implementation Details**:
Uses multiple `nvim --remote-expr` queries:
- `expand('%:p')` - Full file path
- `line('.')` - Current line
- `col('.')` - Current column
- `mode()` - Editor mode
- `&modified` - Modified flag
- `&filetype` - Filetype
- `line('$')` - Total lines

## Socket Management

### Creating Sockets

Neovim must be started with the `--listen` flag:

```bash
# In tmux, with socket for current pane
PANE_ID=$(tmux display-message -p "#{pane_id}" | sed 's/^%//')
nvim --listen /tmp/nvim-tmux-pane-${PANE_ID}
```

### Checking Socket Health

Verify socket is active:

```bash
# Method 1: Simple file test
if [[ -S /tmp/nvim-tmux-pane-15 ]]; then
  echo "Socket exists"
fi

# Method 2: Test connection
if nvim --server /tmp/nvim-tmux-pane-15 --remote-expr "1" 2>/dev/null; then
  echo "Socket active"
fi
```

### Cleaning Stale Sockets

Remove sockets for non-existent panes:

```bash
for socket in /tmp/nvim-tmux-pane-*; do
  if [[ -S "$socket" ]]; then
    pane_id=$(basename "$socket" | sed 's/nvim-tmux-pane-//')
    if ! tmux list-panes -a -F "#{pane_id}" | grep -q "^%${pane_id}$"; then
      echo "Removing stale socket: $socket"
      rm "$socket"
    fi
  fi
done
```

### Multiple Instances

Working with multiple Neovim instances:

```bash
# List all instances
nvim-socket list

# Target specific instance
nvim-remote -s /tmp/nvim-tmux-pane-15 status
nvim-remote -s /tmp/nvim-tmux-pane-28 status

# Operate on all instances
for socket in /tmp/nvim-tmux-pane-*; do
  if [[ -S "$socket" ]]; then
    echo "Instance: $socket"
    nvim-remote -s "$socket" status
  fi
done
```

## Advanced Usage

### Scripting with nvim-remote

**Example: Open file only if not already open**

```bash
#!/usr/bin/env bash
TARGET_FILE="/path/to/file.txt"

# Get current file
CURRENT=$(nvim-remote status | grep "^File:" | cut -d' ' -f2-)

if [[ "$CURRENT" != "$TARGET_FILE" ]]; then
  nvim-remote edit "$TARGET_FILE"
  echo "Opened $TARGET_FILE"
else
  echo "File already open"
fi
```

**Example: Search and report results**

```bash
#!/usr/bin/env bash
PATTERN="$1"

# Perform search
nvim-remote search "$PATTERN"

# Get cursor position to verify match
LINE=$(nvim-remote status | grep "^Position:" | awk '{print $3}' | tr -d ',')

echo "Search completed. Cursor at line: $LINE"
```

**Example: Save current file before editing new one**

```bash
#!/usr/bin/env bash
NEW_FILE="$1"

# Check if current file has unsaved changes
MODIFIED=$(nvim-remote status | grep "^Modified:" | awk '{print $2}')

if [[ "$MODIFIED" == "1" ]]; then
  echo "Saving current file..."
  nvim-remote -s "$(nvim-socket auto)" --remote-send ':w<CR>'
  sleep 0.1  # Give time to save
fi

# Open new file
nvim-remote edit "$NEW_FILE"
```

### Integration with Other Tools

**With fzf for file selection**:

```bash
#!/usr/bin/env bash
# Select file with fzf and open at line 1
FILE=$(find . -type f | fzf)
if [[ -n "$FILE" ]]; then
  nvim-remote edit "$FILE" 1
fi
```

**With ripgrep for search results**:

```bash
#!/usr/bin/env bash
# Search with ripgrep, select result, open in Neovim
RESULT=$(rg -n "$1" | fzf)
if [[ -n "$RESULT" ]]; then
  FILE=$(echo "$RESULT" | cut -d: -f1)
  LINE=$(echo "$RESULT" | cut -d: -f2)
  nvim-remote edit "$FILE" "$LINE"
fi
```

**With git for viewing changes**:

```bash
#!/usr/bin/env bash
# Open files with git changes
FILES=$(git diff --name-only)
for file in $FILES; do
  nvim-remote edit "$file"
  read -p "Press enter for next file..."
done
```

### Batch Operations

**Open multiple files**:

```bash
#!/usr/bin/env bash
# Open files in sequence
for file in *.md; do
  nvim-remote edit "$file"
  sleep 1  # Brief delay between files
done
```

**Search across files**:

```bash
#!/usr/bin/env bash
PATTERN="$1"

for file in src/*.py; do
  nvim-remote edit "$file"
  nvim-remote search "$PATTERN"
  read -p "Next file? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    break
  fi
done
```

## Troubleshooting

### No Socket Found

**Symptom**: `nvim-socket auto` returns "No Neovim sockets found"

**Diagnosis**:
```bash
# Check for any sockets
ls -la /tmp/nvim-*

# Check tmux is running
tmux ls

# Verify Neovim is running in tmux
tmux list-panes -a -F "#{pane_id} #{pane_current_command}"
```

**Solutions**:
1. Start Neovim with socket:
   ```bash
   PANE_ID=$(tmux display-message -p "#{pane_id}" | sed 's/^%//')
   nvim --listen /tmp/nvim-tmux-pane-${PANE_ID}
   ```

2. Check Neovim version supports `--listen`:
   ```bash
   nvim --version | grep "nvim"
   ```

3. Verify socket directory is writable:
   ```bash
   touch /tmp/test-socket && rm /tmp/test-socket
   ```

### Socket Exists But Commands Fail

**Symptom**: Socket file exists but `nvim-remote` fails

**Diagnosis**:
```bash
# Test socket connection
SOCKET=/tmp/nvim-tmux-pane-15
if nvim --server "$SOCKET" --remote-expr "1" 2>&1; then
  echo "Socket active"
else
  echo "Socket stale or inactive"
fi
```

**Solutions**:
1. Socket is stale (Neovim crashed):
   ```bash
   # Remove stale socket
   rm /tmp/nvim-tmux-pane-15

   # Restart Neovim with socket
   nvim --listen /tmp/nvim-tmux-pane-15
   ```

2. Permissions issue:
   ```bash
   # Check socket permissions
   ls -l /tmp/nvim-tmux-pane-15

   # Should be owned by you and type 's' (socket)
   ```

3. Neovim frozen or unresponsive:
   ```bash
   # Identify Neovim process
   ps aux | grep "nvim.*listen"

   # Send SIGTERM (try graceful shutdown first)
   kill <PID>

   # If unresponsive, force kill
   kill -9 <PID>
   ```

### File Not Opening at Correct Line

**Symptom**: `nvim-remote edit file.txt 42` opens file but cursor at line 1

**Diagnosis**:
```bash
# Check if line command was sent
nvim-remote edit file.txt 42

# Immediately check position
nvim-remote status | grep Position
```

**Solutions**:
1. Add delay if timing issue:
   ```bash
   nvim-remote edit file.txt
   sleep 0.2
   nvim-remote goto 42
   ```

2. Use separate goto command:
   ```bash
   nvim-remote edit file.txt && nvim-remote goto 42
   ```

3. Verify file has that many lines:
   ```bash
   wc -l file.txt
   ```

### Search Not Finding Matches

**Symptom**: `nvim-remote search "pattern"` doesn't find expected matches

**Diagnosis**:
```bash
# Verify pattern syntax
nvim-remote search "pattern"

# Check current file has content
nvim-remote status
```

**Solutions**:
1. Pattern escaping issue:
   ```bash
   # Escape special characters
   nvim-remote search "exact\.pattern"  # Literal dot
   ```

2. Case sensitivity:
   ```bash
   # Make search case-insensitive (in Neovim first)
   nvim --server "$SOCKET" --remote-send ':set ignorecase<CR>'
   nvim-remote search "pattern"
   ```

3. Wrong buffer:
   ```bash
   # Verify correct file is open
   nvim-remote status | grep File

   # Open correct file
   nvim-remote edit correct-file.txt
   nvim-remote search "pattern"
   ```

### Auto-Detection Picks Wrong Socket

**Symptom**: `nvim-socket auto` selects unexpected instance

**Diagnosis**:
```bash
# List all sockets with context
nvim-socket list

# Check current pane
tmux display-message -p "Pane: #{pane_id}, Window: #{window_index}, Dir: #{pane_current_path}"
```

**Solutions**:
1. Use explicit socket:
   ```bash
   nvim-remote -s /tmp/nvim-tmux-pane-28 edit file.txt
   ```

2. Set environment variable:
   ```bash
   export NVIM_SOCKET_PATH=/tmp/nvim-tmux-pane-28
   nvim-remote edit file.txt
   ```

3. Ensure Neovim running in expected pane:
   ```bash
   # Check which pane has Neovim
   tmux list-panes -a -F "#{pane_id} #{pane_current_command}"
   ```

### Permission Denied Errors

**Symptom**: Cannot create or access socket files

**Diagnosis**:
```bash
# Check /tmp permissions
ls -ld /tmp

# Check existing socket permissions
ls -l /tmp/nvim-*

# Check your user
whoami
```

**Solutions**:
1. Clean up old sockets:
   ```bash
   rm /tmp/nvim-tmux-pane-*
   ```

2. Use alternative socket directory:
   ```bash
   # Create user-specific socket dir
   mkdir -p ~/.local/nvim-sockets

   # Start Neovim with custom path
   nvim --listen ~/.local/nvim-sockets/pane-15
   ```

3. Check umask:
   ```bash
   # View current umask
   umask

   # Set permissive umask temporarily
   umask 0077
   ```

## Technical Details

### CLI Commands Used

The implementation uses these `nvim` CLI commands:

**Opening files**:
```bash
nvim --server <socket> --remote <file>
```

**Sending keystrokes**:
```bash
nvim --server <socket> --remote-send '<keys>'
```

**Evaluating expressions**:
```bash
nvim --server <socket> --remote-expr '<expression>'
```

### Vim Expressions Reference

Common expressions used for queries:

| Expression | Returns | Example |
|------------|---------|---------|
| `expand('%:p')` | Full file path | `/home/user/file.txt` |
| `expand('%:t')` | File name only | `file.txt` |
| `line('.')` | Current line | `42` |
| `col('.')` | Current column | `15` |
| `line('$')` | Total lines | `256` |
| `mode()` | Current mode | `n`, `i`, `v` |
| `&modified` | Modified flag | `0` or `1` |
| `&filetype` | Filetype | `python`, `markdown` |
| `getline(N)` | Line N content | `def main():` |
| `getline(1, 5)` | Lines 1-5 | `['line1', 'line2', ...]` |

### Vim Commands Reference

Common commands sent via `--remote-send`:

| Command | Action |
|---------|--------|
| `:w<CR>` | Save file |
| `:q<CR>` | Quit |
| `:wq<CR>` | Save and quit |
| `:e file<CR>` | Edit file |
| `:100<CR>` | Go to line 100 |
| `/pattern<CR>` | Search for pattern |
| `n` | Next search match |
| `N` | Previous search match |
| `gg` | Go to first line |
| `G` | Go to last line |
| `:set number<CR>` | Show line numbers |

### Performance Considerations

**Socket Operation Speed**:
- `--remote-expr` queries: ~10-50ms per query
- `--remote-send` commands: ~5-20ms per command
- `--remote` file opening: ~20-100ms

**Optimization Tips**:
1. Batch multiple `--remote-send` commands:
   ```bash
   nvim --server "$SOCKET" --remote-send ':100<CR>/TODO<CR>'
   ```

2. Cache socket path for repeated operations:
   ```bash
   SOCKET=$(nvim-socket auto)
   nvim-remote -s "$SOCKET" edit file1.txt
   nvim-remote -s "$SOCKET" edit file2.txt
   ```

3. Minimize `status` queries in loops (expensive)

### Compatibility

**Neovim Versions**:
- Minimum: v0.7.0 (introduced `--server` support)
- Tested: v0.9.0+
- Recommended: Latest stable release

**Platform Support**:
- ✅ Linux (any distribution)
- ✅ macOS (all versions)
- ✅ WSL (Windows Subsystem for Linux)
- ❌ Windows (native) - tmux not available

**Shell Requirements**:
- bash 3.2+ (macOS default)
- bash 4.0+ (Linux)
- Common utilities: `sed`, `grep`, `tmux`, `realpath`

## See Also

- [SKILL.md](../SKILL.md) - Agent-facing quick reference
- [tests/CLI-TEST-RESULTS.md](../../../tests/CLI-TEST-RESULTS.md) - Validation results
- [tests/test-cli-alternatives.sh](../../../tests/test-cli-alternatives.sh) - Test suite
- Neovim documentation: `:help --server`
- Tmux documentation: `man tmux`

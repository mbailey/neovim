# Neovim LSP Code Navigation

Master code navigation in Neovim using Language Server Protocol (LSP) for tracing function calls and understanding code flow.

## Why LSP > ctags

**ctags** (old way):
- Generates giant static tag files
- Gets out of date immediately after code changes
- Dumb text matching, no semantic understanding
- Requires constant regeneration

**LSP** (modern way):
- Live, dynamic analysis as you code
- Understands language semantics (types, imports, context)
- No tag files to manage
- Works across files intelligently
- Provides IDE features (autocomplete, hover docs, refactoring)

## Your Setup: LazyVim

You're using LazyVim, which includes LSP support out of the box:
- `nvim-lspconfig` - LSP client configuration
- `mason.nvim` - Language server installer
- Pre-configured keybindings

## Check if LSP is Installed

### 1. Check LazyVim is Loaded
Open Neovim and type:
```
:Lazy
```
You should see the plugin manager with many installed plugins.

### 2. Check Mason
Type:
```
:Mason
```
This opens the language server installer. You'll see a list of available language servers.

### 3. Check LSP Info
Open any Python file and type:
```
:LspInfo
```
This shows which language servers are attached to the current buffer.

## Install Python LSP (Pyright)

### Method 1: Via Mason (Recommended)
1. Open Neovim
2. Type `:Mason`
3. Search for "pyright" (use `/` to search)
4. Move cursor to "pyright"
5. Press `i` to install
6. Wait for installation to complete

### Method 2: Via Command Line
```bash
# Mason installs to ~/.local/share/nvim/mason/bin/
# But it's easier to use the UI
:MasonInstall pyright
```

### Verify Installation
1. Open a Python file (`.py`)
2. Look for "LSP attached" notification in bottom right
3. Type `:LspInfo` - should show "pyright" as attached

## Essential LSP Keybindings

LazyVim default keybindings for LSP:

### Navigation
| Key | Action | Description |
|-----|--------|-------------|
| `gd` | Go to Definition | Jump to where function/variable is defined |
| `gD` | Go to Declaration | Jump to declaration (rarely different from definition) |
| `gr` | Find References | Show all places this function/variable is used |
| `gi` | Go to Implementation | Jump to implementation (useful for interfaces) |
| `K` | Hover Documentation | Show docstring/type info under cursor |

### Code Actions
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>ca` | Code Actions | Show available fixes/refactorings |
| `<leader>cr` | Rename | Rename symbol across entire codebase |
| `<leader>cd` | Line Diagnostics | Show error/warning details |

### Jump List Navigation
| Key | Action | Description |
|-----|--------|-------------|
| `Ctrl-o` | Jump Back | Go to previous location (like browser back) |
| `Ctrl-i` | Jump Forward | Go to next location (like browser forward) |

### File Navigation
| Key | Action | Description |
|-----|--------|-------------|
| `gf` | Go to File | Open file path under cursor |
| `<C-w>f` | Open in Split | Open file in horizontal split |

## Code Reading Workflow

### 1. Start at Entry Point
For Python CLI tools:
1. Open `pyproject.toml`
2. Find `[project.scripts]` section
3. Put cursor on the module path (e.g., `voice_mode.cli:voice_mode`)
4. Press `gf` - opens the module file

### 2. Trace Function Calls
1. Find the entry function in the opened file
2. Put cursor on any function name that's called
3. Press `gd` - jumps to that function's definition
4. Continue following the chain

### 3. Navigate the Call Stack
As you jump through functions:
- `Ctrl-o` - Go back to previous location
- `Ctrl-i` - Go forward (if you went back)
- `gd` - Follow the next function call

### 4. Find All Uses
To see where a function is called:
1. Put cursor on function name
2. Press `gr` - opens quickfix with all references
3. Navigate through the list

### 5. Multi-Pane View with tmux
Split tmux to see multiple parts of the call stack:
```bash
# Horizontal split
Ctrl-b "

# Vertical split
Ctrl-b %

# Navigate between panes
Ctrl-b arrow-keys
```

In each pane, open different files in the call chain.

## Example: Tracing `voicemode converse`

### Step-by-step walkthrough:

1. **Start at entry point:**
   ```bash
   nvim ~/Code/github.com/mbailey/voicemode/pyproject.toml
   ```
   - Find line with `voicemode = "voice_mode.cli:voice_mode"`
   - Cursor on `voice_mode.cli:voice_mode`
   - Press `gf` → Opens `voice_mode/cli.py`

2. **Find entry function:**
   - Search for `def voice_mode()` (press `/voice_mode`)
   - Press `n` to find the function definition
   - See it calls `voice_mode_main_cli()`

3. **Jump to main CLI:**
   - Cursor on `voice_mode_main_cli`
   - Press `gd` → Jumps to function definition
   - See it's a Click command group

4. **Find converse subcommand:**
   - Search for `def converse` (`/def converse`)
   - See the `@voice_mode_main_cli.command()` decorator
   - This is the CLI wrapper

5. **Jump to tool implementation:**
   - Inside `converse()`, find the import: `from voice_mode.tools.converse import converse`
   - Cursor on the second `converse` in that line
   - Press `gd` → Opens `voice_mode/tools/converse.py` at the tool definition

6. **Explore core functions:**
   - See `text_to_speech()` call
   - Press `gd` on it → Opens `voice_mode/core.py`
   - Continue tracing as needed

7. **Return to previous locations:**
   - Press `Ctrl-o` repeatedly to go back through your jump history
   - Each press takes you to where you were before

## Advanced Techniques

### Search Functions Across Project
Using Telescope (included in LazyVim):
```
<leader>ff  - Find files (fuzzy search)
<leader>fg  - Live grep (search in file contents)
<leader>fs  - Find symbols (LSP symbols in current file)
<leader>fS  - Find symbols in workspace
```

### Search for Definitions
Using ripgrep from command line:
```bash
# Find all function definitions matching pattern
rg "^async def converse" voice_mode/

# Find all class definitions
rg "^class \w+" voice_mode/
```

### Navigate by Symbols
With LSP attached:
```
<leader>fs  - Browse symbols in current file
```
Shows outline of all functions/classes, navigate and jump.

## Troubleshooting

### LSP Not Attaching
1. Check LSP is installed: `:Mason` → look for pyright
2. Check for errors: `:LspInfo`
3. Restart LSP: `:LspRestart`
4. Check logs: `:LspLog`

### Go to Definition Not Working
1. Verify LSP is attached: `:LspInfo` should show active server
2. Make sure you're in a Python file (`.py` extension)
3. Try `:LspRestart`
4. Check Pyright is installed: `:Mason`

### No Hover Documentation
1. Position cursor directly on the symbol (function/variable name)
2. Press `K` (capital K)
3. If nothing happens, LSP may not be attached

## Tips for Efficient Code Reading

1. **Use the Jump List**: `Ctrl-o` is your best friend. Go deep, then pop back out.

2. **Split Your View**: Use tmux or Neovim splits to see multiple parts of the call stack simultaneously.

3. **Don't Read Everything**: Focus on the main execution path. Skip helper functions initially.

4. **Take Notes**: Keep a scratchpad file open with the call stack you've discovered.

5. **Use Telescope**: When LSP jump doesn't work (external libraries), fall back to fuzzy finding.

6. **Trust LSP**: Unlike ctags, LSP go-to-definition is semantic - it understands imports, namespaces, and context.

## Related Tools

- **Telescope** - Fuzzy finder (already in LazyVim)
- **nvim-treesitter** - Better syntax highlighting and code understanding
- **Aerial** - Code outline sidebar (shows all functions/classes)
- **Trouble** - Better diagnostics panel

## Quick Reference Card

```
┌─────────────────────────────────────────────┐
│         Neovim LSP Navigation              │
├─────────────────────────────────────────────┤
│ gd         Go to Definition                │
│ gr         Find References                  │
│ K          Hover Documentation              │
│ Ctrl-o     Jump Back                        │
│ Ctrl-i     Jump Forward                     │
│ gf         Go to File                       │
│ <leader>ca Code Actions                     │
│ <leader>cr Rename Symbol                    │
└─────────────────────────────────────────────┘
```

## Example Session Recording

See the generated code reading guide for voicemode:
```
~/Code/github.com/mbailey/voicemode/code-reading-guide.md
```

This was created using the workflow described here.

## Created By

Cora 7 - Your AI assistant
Date: 2025-10-11

## See Also

- `/create-code-guide` - Slash command to auto-generate code reading guides
- `~/.cora/tools/code-guides/` - Code reading methodology documentation

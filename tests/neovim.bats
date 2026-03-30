#!/usr/bin/env bats
# BATS tests for neovim command

# Setup - find the neovim script
setup() {
    # Get the package directory
    PACKAGE_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    NEOVIM_CMD="$PACKAGE_DIR/bin/neovim"

    # Ensure the script exists
    [ -f "$NEOVIM_CMD" ]
    [ -x "$NEOVIM_CMD" ]
}

# Test: Command exists and is executable
@test "neovim command exists and is executable" {
    [ -f "$NEOVIM_CMD" ]
    [ -x "$NEOVIM_CMD" ]
}

# Test: Help flag works
@test "neovim --help shows help" {
    run "$NEOVIM_CMD" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Neovim package management and utilities" ]]
}

# Test: Short help flag works
@test "neovim -h shows help" {
    run "$NEOVIM_CMD" -h
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Neovim package management and utilities" ]]
}

# Test: Version flag works
@test "neovim --version shows version" {
    run "$NEOVIM_CMD" --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "neovim, version" ]]
}

# Test: LSP subcommand exists
@test "neovim lsp --help shows LSP help" {
    run "$NEOVIM_CMD" lsp --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Language Server Protocol" ]]
}

# Test: LSP subcommand with short help
@test "neovim lsp -h shows LSP help" {
    run "$NEOVIM_CMD" lsp -h
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Language Server Protocol" ]]
}

# Test: LSP check command exists
@test "neovim lsp check --help shows check help" {
    run "$NEOVIM_CMD" lsp check --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Check LSP installation" ]]
}

# Test: LSP install command exists
@test "neovim lsp install --help shows install help" {
    run "$NEOVIM_CMD" lsp install --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Install a language server" ]]
}

# Test: LSP status command exists
@test "neovim lsp status --help shows status help" {
    run "$NEOVIM_CMD" lsp status --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Show LSP status" ]]
}

# Test: Docs subcommand exists
@test "neovim docs --help shows docs help" {
    run "$NEOVIM_CMD" docs --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "View package documentation" ]]
}

# Test: Docs subcommand with short help
@test "neovim docs -h shows docs help" {
    run "$NEOVIM_CMD" docs -h
    [ "$status" -eq 0 ]
    [[ "$output" =~ "View package documentation" ]]
}

# Test: Clean command exists
@test "neovim clean --help shows clean help" {
    run "$NEOVIM_CMD" clean --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Clean Neovim swap files" ]]
}

# Test: Tmux command exists
@test "neovim tmux --help shows tmux help" {
    run "$NEOVIM_CMD" tmux --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Open Neovim in a tmux split" ]]
}

# Test: Invalid subcommand shows error
@test "neovim invalid-command shows error" {
    run "$NEOVIM_CMD" invalid-command
    [ "$status" -ne 0 ]
    [[ "$output" =~ "Error" ]] || [[ "$output" =~ "No such command" ]]
}

# Test: LSP check runs without errors (may show warnings if LSP not installed)
@test "neovim lsp check runs" {
    run "$NEOVIM_CMD" lsp check
    # Should exit successfully even if components aren't installed
    # (it just reports status)
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

# Test: All commands listed in main help
@test "neovim help lists all commands" {
    run "$NEOVIM_CMD" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "lsp" ]]
    [[ "$output" =~ "docs" ]]
    [[ "$output" =~ "clean" ]]
    [[ "$output" =~ "tmux" ]]
}

# Test: LSP help lists all subcommands
@test "neovim lsp help lists all LSP commands" {
    run "$NEOVIM_CMD" lsp --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "check" ]]
    [[ "$output" =~ "install" ]]
    [[ "$output" =~ "status" ]]
}

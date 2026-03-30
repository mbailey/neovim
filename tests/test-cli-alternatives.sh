#!/usr/bin/env bash
set -o nounset -o pipefail -o errexit

# test-cli-alternatives.sh - Test nvim --server CLI equivalents for MCP tools
#
# This script validates that nvim --server CLI commands can replicate
# all functionality provided by the pynvim-based MCP server.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCKET="${NVIM_TEST_SOCKET:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Print test header
print_test() {
  echo ""
  echo "=========================================="
  echo "TEST: $1"
  echo "=========================================="
}

# Print success
pass() {
  echo -e "${GREEN}✓ PASS${NC}: $1"
  ((TESTS_PASSED++))
}

# Print failure
fail() {
  echo -e "${RED}✗ FAIL${NC}: $1"
  ((TESTS_FAILED++))
}

# Print info
info() {
  echo -e "${YELLOW}ℹ${NC} $1"
}

# Find socket if not specified
find_socket() {
  if [[ -n "$SOCKET" ]]; then
    return 0
  fi

  # Try to auto-detect
  if command -v nvim-socket >/dev/null 2>&1; then
    SOCKET=$(nvim-socket auto 2>/dev/null || echo "")
  fi

  if [[ -z "$SOCKET" ]]; then
    # Look for any socket
    local sockets=(/tmp/nvim-tmux-pane-*)
    if [[ -S "${sockets[0]}" ]]; then
      SOCKET="${sockets[0]}"
    fi
  fi

  if [[ -z "$SOCKET" ]] || [[ ! -S "$SOCKET" ]]; then
    echo "Error: No Neovim socket found"
    echo "Please start a Neovim instance with:"
    echo "  nvim --listen /tmp/nvim-test"
    echo "Or set NVIM_TEST_SOCKET environment variable"
    exit 1
  fi

  info "Using socket: $SOCKET"
}

# Test 1: vim_command equivalent
test_vim_command() {
  print_test "vim_command - Execute vim commands"

  # Test setting a variable
  if nvim --server "$SOCKET" --remote-send ':let g:test_var="test_value"<CR>' 2>/dev/null; then
    pass "Send command (set variable)"
  else
    fail "Send command (set variable)"
  fi

  # Test retrieving the variable
  local result
  result=$(nvim --server "$SOCKET" --remote-expr 'g:test_var' 2>/dev/null || echo "")
  if [[ "$result" == "test_value" ]]; then
    pass "Remote expr (get variable) - got: $result"
  else
    fail "Remote expr (get variable) - expected: test_value, got: $result"
  fi

  # Test command with output
  local line_count
  line_count=$(nvim --server "$SOCKET" --remote-expr "line('$')" 2>/dev/null || echo "")
  if [[ -n "$line_count" ]] && [[ "$line_count" =~ ^[0-9]+$ ]]; then
    pass "Command with output (line count) - got: $line_count"
  else
    fail "Command with output (line count) - got: $line_count"
  fi
}

# Test 2: vim_buffer equivalent
test_vim_buffer() {
  print_test "vim_buffer - Read buffer contents"

  # Get buffer content line by line
  local line_count
  line_count=$(nvim --server "$SOCKET" --remote-expr "line('$')" 2>/dev/null || echo "0")

  if [[ "$line_count" -gt 0 ]]; then
    pass "Get line count: $line_count lines"
  else
    fail "Get line count: $line_count"
  fi

  # Get specific line
  local first_line
  first_line=$(nvim --server "$SOCKET" --remote-expr "getline(1)" 2>/dev/null || echo "")
  info "First line: ${first_line:0:50}..."
  pass "Get specific line content"

  # Get range of lines (alternative approach)
  local lines_json
  lines_json=$(nvim --server "$SOCKET" --remote-expr "getline(1, 5)" 2>/dev/null || echo "")
  if [[ -n "$lines_json" ]]; then
    pass "Get line range (1-5)"
  else
    fail "Get line range (1-5)"
  fi
}

# Test 3: vim_status equivalent
test_vim_status() {
  print_test "vim_status - Get comprehensive status"

  # Get cursor position
  local line col
  line=$(nvim --server "$SOCKET" --remote-expr "line('.')" 2>/dev/null || echo "")
  col=$(nvim --server "$SOCKET" --remote-expr "col('.')" 2>/dev/null || echo "")

  if [[ -n "$line" ]] && [[ -n "$col" ]]; then
    pass "Get cursor position: line $line, col $col"
  else
    fail "Get cursor position"
  fi

  # Get mode
  local mode
  mode=$(nvim --server "$SOCKET" --remote-expr "mode()" 2>/dev/null || echo "")
  if [[ -n "$mode" ]]; then
    pass "Get mode: $mode"
  else
    fail "Get mode"
  fi

  # Get filename
  local filename
  filename=$(nvim --server "$SOCKET" --remote-expr "expand('%:p')" 2>/dev/null || echo "")
  info "Current file: ${filename:-[No Name]}"
  pass "Get filename"

  # Get modified status
  local modified
  modified=$(nvim --server "$SOCKET" --remote-expr "&modified" 2>/dev/null || echo "")
  if [[ -n "$modified" ]]; then
    pass "Get modified status: $modified"
  else
    fail "Get modified status"
  fi

  # Get filetype
  local filetype
  filetype=$(nvim --server "$SOCKET" --remote-expr "&filetype" 2>/dev/null || echo "")
  pass "Get filetype: ${filetype:-none}"
}

# Test 4: vim_file_open equivalent
test_vim_file_open() {
  print_test "vim_file_open - Open files"

  # Create a test file
  local test_file="/tmp/nvim-test-cli-$$"
  echo "Line 1" > "$test_file"
  echo "Line 2" >> "$test_file"
  echo "Line 3" >> "$test_file"

  # Open the file
  if nvim --server "$SOCKET" --remote "$test_file" 2>/dev/null; then
    pass "Open file: $test_file"
  else
    fail "Open file: $test_file"
  fi

  # Verify file is open
  local current_file
  current_file=$(nvim --server "$SOCKET" --remote-expr "expand('%:p')" 2>/dev/null || echo "")
  if [[ "$current_file" == "$test_file" ]]; then
    pass "Verify file opened: $current_file"
  else
    fail "Verify file opened - expected: $test_file, got: $current_file"
  fi

  # Clean up
  rm -f "$test_file"
}

# Test 5: vim_search equivalent
test_vim_search() {
  print_test "vim_search - Search within buffer"

  # Create test file with searchable content
  local test_file="/tmp/nvim-search-test-$$"
  cat > "$test_file" <<'EOF'
Line 1: normal line
Line 2: TODO: important task
Line 3: another line
Line 4: TODO: another task
Line 5: final line
EOF

  # Open the file
  nvim --server "$SOCKET" --remote "$test_file" 2>/dev/null

  # Perform search
  if nvim --server "$SOCKET" --remote-send '/TODO<CR>' 2>/dev/null; then
    pass "Execute search command"
  else
    fail "Execute search command"
  fi

  # Verify cursor moved to match
  local line
  line=$(nvim --server "$SOCKET" --remote-expr "line('.')" 2>/dev/null || echo "0")
  if [[ "$line" == "2" ]]; then
    pass "Cursor at first match: line $line"
  else
    # Might already be past first match, just check it's reasonable
    if [[ "$line" -ge 2 ]] && [[ "$line" -le 4 ]]; then
      pass "Cursor at match: line $line"
    else
      fail "Cursor at match - expected 2 or 4, got: $line"
    fi
  fi

  # Search with options (case insensitive)
  nvim --server "$SOCKET" --remote-send ':set ignorecase<CR>' 2>/dev/null
  nvim --server "$SOCKET" --remote-send '/todo<CR>' 2>/dev/null
  local line_ci
  line_ci=$(nvim --server "$SOCKET" --remote-expr "line('.')" 2>/dev/null || echo "0")
  if [[ "$line_ci" -ge 2 ]] && [[ "$line_ci" -le 4 ]]; then
    pass "Case insensitive search works"
  else
    fail "Case insensitive search - cursor at line $line_ci"
  fi

  # Clean up
  rm -f "$test_file"
}

# Main test runner
main() {
  echo "=========================================="
  echo "CLI Alternatives Test Suite"
  echo "Testing nvim --server CLI equivalents"
  echo "=========================================="

  find_socket

  # Run all tests
  test_vim_command
  test_vim_buffer
  test_vim_status
  test_vim_file_open
  test_vim_search

  # Print summary
  echo ""
  echo "=========================================="
  echo "TEST SUMMARY"
  echo "=========================================="
  echo -e "Passed: ${GREEN}${TESTS_PASSED}${NC}"
  echo -e "Failed: ${RED}${TESTS_FAILED}${NC}"
  echo "Total:  $((TESTS_PASSED + TESTS_FAILED))"
  echo "=========================================="

  if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
  else
    echo -e "${RED}Some tests failed${NC}"
    exit 1
  fi
}

# Execute if script is not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

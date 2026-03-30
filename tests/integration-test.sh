#!/usr/bin/env bash
set -o nounset -o pipefail -o errexit

# integration-test.sh - Integration test suite for Neovim remote control
#
# Tests the complete workflow from socket discovery to file operations
# in a tmux environment with multiple panes.
#
# Prerequisites:
# - Running in tmux
# - At least one Neovim instance with socket (nvim --listen)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$(cd "$SCRIPT_DIR/../bin" && pwd)"

# Add bin directory to PATH for testing
export PATH="$BIN_DIR:$PATH"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Print section header
section() {
  echo ""
  echo -e "${BLUE}>>> $1${NC}"
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

# Check if in tmux
check_tmux() {
  if [[ -z "${TMUX:-}" ]]; then
    echo "Error: Not running in tmux"
    echo "Please run this script from within a tmux session"
    exit 1
  fi
  pass "Running in tmux session"
}

# Check for Neovim instances
check_neovim_instances() {
  local socket_count
  socket_count=$(nvim-socket list 2>/dev/null | tail -n +3 | wc -l | tr -d ' ')

  if [[ "$socket_count" -eq 0 ]]; then
    echo ""
    echo -e "${YELLOW}SKIP: No Neovim instances with sockets found${NC}"
    echo ""
    echo "To run integration tests, start Neovim in a tmux pane with:"
    echo "  nvim --listen /tmp/nvim-tmux-pane-\$(tmux display-message -p '#{pane_id}' | sed 's/%//')"
    echo ""
    echo "Or simply:"
    echo "  nvim-tmux"
    echo ""
    exit 0
  fi

  info "Found $socket_count Neovim socket(s)"
  pass "Neovim instances available for testing"
}

# Test 1: Socket Discovery
test_socket_discovery() {
  print_test "Socket Discovery"

  section "1.1: nvim-socket list"
  if nvim-socket list >/dev/null 2>&1; then
    pass "nvim-socket list command works"
  else
    fail "nvim-socket list command failed"
    return
  fi

  section "1.2: Count available sockets"
  local socket_count
  socket_count=$(nvim-socket list 2>/dev/null | tail -n +3 | wc -l | tr -d ' ')
  info "Found $socket_count Neovim socket(s)"

  if [[ "$socket_count" -gt 0 ]]; then
    pass "At least one Neovim socket available"
  else
    fail "No Neovim sockets found - start Neovim with --listen first"
    return
  fi

  section "1.3: nvim-socket auto-detect"
  local auto_socket
  auto_socket=$(nvim-socket auto 2>&1)

  if [[ $? -eq 0 ]] && [[ -n "$auto_socket" ]]; then
    pass "Auto-detection successful: $auto_socket"
  else
    fail "Auto-detection failed"
    return
  fi

  section "1.4: Verify socket is valid"
  if [[ -S "$auto_socket" ]]; then
    pass "Socket file exists and is a socket"
  else
    fail "Socket file not valid: $auto_socket"
  fi

  section "1.5: nvim-socket show context"
  if nvim-socket show >/dev/null 2>&1; then
    pass "nvim-socket show command works"

    # Display context for info
    info "Socket context:"
    nvim-socket show 2>&1 | while IFS= read -r line; do
      info "  $line"
    done
  else
    fail "nvim-socket show command failed"
  fi
}

# Test 2: Remote Status Query
test_remote_status() {
  print_test "Remote Status Query"

  section "2.1: nvim-remote status"
  local status_output
  status_output=$(nvim-remote status 2>&1)

  if [[ $? -eq 0 ]]; then
    pass "nvim-remote status command works"
  else
    fail "nvim-remote status command failed"
    return
  fi

  section "2.2: Verify status fields"
  local has_socket has_file has_position has_mode

  has_socket=$(echo "$status_output" | grep -c "^Socket:" || true)
  has_file=$(echo "$status_output" | grep -c "^File:" || true)
  has_position=$(echo "$status_output" | grep -c "^Position:" || true)
  has_mode=$(echo "$status_output" | grep -c "^Mode:" || true)

  if [[ "$has_socket" -eq 1 ]]; then
    pass "Status includes socket path"
  else
    fail "Status missing socket path"
  fi

  if [[ "$has_file" -eq 1 ]]; then
    pass "Status includes file path"
  else
    fail "Status missing file path"
  fi

  if [[ "$has_position" -eq 1 ]]; then
    pass "Status includes cursor position"
  else
    fail "Status missing cursor position"
  fi

  if [[ "$has_mode" -eq 1 ]]; then
    pass "Status includes mode"
  else
    fail "Status missing mode"
  fi
}

# Test 3: File Operations
test_file_operations() {
  print_test "File Operations"

  # Create test file
  local test_file="/tmp/nvim-integration-test-$$.txt"
  cat > "$test_file" <<'EOF'
Line 1: Integration test file
Line 2: Second line with TODO marker
Line 3: Third line
Line 4: Another TODO here
Line 5: Fifth line
Line 6: Sixth line with FIXME
Line 7: Final line
EOF

  section "3.1: Open file"
  if nvim-remote edit "$test_file" 2>&1; then
    pass "File opened successfully"
  else
    fail "File open failed"
    rm -f "$test_file"
    return
  fi

  sleep 0.3  # Give Neovim time to process

  section "3.2: Verify file is open"
  local current_file
  current_file=$(nvim-remote status 2>&1 | grep "^File:" | cut -d' ' -f2-)

  if [[ "$current_file" == "$test_file" ]]; then
    pass "Correct file is open: $(basename "$test_file")"
  else
    fail "Expected $test_file, got $current_file"
  fi

  section "3.3: Open file at specific line"
  if nvim-remote edit "$test_file" 5 2>&1; then
    pass "File opened at line 5"
  else
    fail "File open at line failed"
  fi

  sleep 0.2

  section "3.4: Verify cursor position"
  local current_line
  current_line=$(nvim-remote status 2>&1 | grep "^Position:" | awk '{print $3}' | tr -d ',')

  if [[ "$current_line" == "5" ]]; then
    pass "Cursor at line 5"
  else
    fail "Expected line 5, cursor at line $current_line"
  fi

  # Cleanup
  rm -f "$test_file"
}

# Test 4: Navigation
test_navigation() {
  print_test "Navigation Commands"

  # Create test file
  local test_file="/tmp/nvim-nav-test-$$.txt"
  cat > "$test_file" <<'EOF'
Line 1
Line 2
Line 3
Line 4
Line 5
Line 6
Line 7
Line 8
Line 9
Line 10
EOF

  nvim-remote edit "$test_file" >/dev/null 2>&1
  sleep 0.2

  section "4.1: Jump to line 7"
  if nvim-remote goto 7 2>&1; then
    pass "goto command executed"
  else
    fail "goto command failed"
  fi

  sleep 0.2

  section "4.2: Verify position after goto"
  local line_after_goto
  line_after_goto=$(nvim-remote status 2>&1 | grep "^Position:" | awk '{print $3}' | tr -d ',')

  if [[ "$line_after_goto" == "7" ]]; then
    pass "Cursor moved to line 7"
  else
    fail "Expected line 7, got line $line_after_goto"
  fi

  section "4.3: Jump to line 1 (first line)"
  nvim-remote goto 1 >/dev/null 2>&1
  sleep 0.2

  local line_at_start
  line_at_start=$(nvim-remote status 2>&1 | grep "^Position:" | awk '{print $3}' | tr -d ',')

  if [[ "$line_at_start" == "1" ]]; then
    pass "Cursor moved to first line"
  else
    fail "Expected line 1, got line $line_at_start"
  fi

  section "4.4: Jump to last line"
  nvim-remote goto 10 >/dev/null 2>&1
  sleep 0.2

  local line_at_end
  line_at_end=$(nvim-remote status 2>&1 | grep "^Position:" | awk '{print $3}' | tr -d ',')

  if [[ "$line_at_end" == "10" ]]; then
    pass "Cursor moved to last line"
  else
    fail "Expected line 10, got line $line_at_end"
  fi

  # Cleanup
  rm -f "$test_file"
}

# Test 5: Search
test_search() {
  print_test "Search Operations"

  # Create test file with searchable content
  local test_file="/tmp/nvim-search-test-$$.txt"
  cat > "$test_file" <<'EOF'
Normal line here
TODO: First task to complete
Another normal line
FIXME: Bug to fix
More content
TODO: Second task
Final line
EOF

  nvim-remote edit "$test_file" >/dev/null 2>&1
  sleep 0.2

  section "5.1: Search for TODO"
  if nvim-remote search "TODO" 2>&1; then
    pass "Search command executed"
  else
    fail "Search command failed"
  fi

  sleep 0.2

  section "5.2: Verify cursor moved to match"
  local line_after_search
  line_after_search=$(nvim-remote status 2>&1 | grep "^Position:" | awk '{print $3}' | tr -d ',')

  # Should be at line 2 (first TODO) or possibly line 6 if already past first match
  if [[ "$line_after_search" -eq 2 ]] || [[ "$line_after_search" -eq 6 ]]; then
    pass "Cursor at TODO line: $line_after_search"
  else
    fail "Expected line 2 or 6, got line $line_after_search"
  fi

  section "5.3: Search for FIXME"
  nvim-remote edit "$test_file" 1 >/dev/null 2>&1  # Reset to line 1
  sleep 0.2
  nvim-remote search "FIXME" >/dev/null 2>&1
  sleep 0.2

  local line_fixme
  line_fixme=$(nvim-remote status 2>&1 | grep "^Position:" | awk '{print $3}' | tr -d ',')

  if [[ "$line_fixme" == "4" ]]; then
    pass "Found FIXME at line 4"
  else
    fail "Expected line 4, got line $line_fixme"
  fi

  section "5.4: Search for non-existent pattern"
  nvim-remote search "NONEXISTENT" >/dev/null 2>&1
  sleep 0.2

  # Cursor should stay at same position if pattern not found
  # (Neovim shows error but doesn't crash)
  local status_after_bad_search
  status_after_bad_search=$(nvim-remote status 2>&1)

  if [[ $? -eq 0 ]]; then
    pass "Neovim stable after failed search"
  else
    fail "Neovim error after failed search"
  fi

  # Cleanup
  rm -f "$test_file"
}

# Test 6: Workflow Integration
test_workflow() {
  print_test "Complete Workflow Integration"

  # Create a realistic test file
  local test_file="/tmp/nvim-workflow-test-$$.py"
  cat > "$test_file" <<'EOF'
def calculate_sum(numbers):
    """Calculate sum of numbers."""
    total = 0
    for num in numbers:
        total += num
    return total

def process_data(data):
    """Process the data."""
    # TODO: Add validation
    result = []
    for item in data:
        result.append(item * 2)
    return result

def main():
    """Main function."""
    numbers = [1, 2, 3, 4, 5]
    total = calculate_sum(numbers)
    print(f"Total: {total}")

if __name__ == "__main__":
    main()
EOF

  section "6.1: Agent discovers available Neovim instances"
  local socket
  socket=$(nvim-socket auto)

  if [[ -n "$socket" ]]; then
    pass "Agent found socket: $(basename "$socket")"
  else
    fail "Agent could not find socket"
    rm -f "$test_file"
    return
  fi

  section "6.2: Agent checks current context"
  local current_context
  current_context=$(nvim-remote status 2>&1)

  if [[ -n "$current_context" ]]; then
    pass "Agent retrieved current context"
    info "  Current file: $(echo "$current_context" | grep "^File:" | cut -d' ' -f2- | xargs basename)"
  else
    fail "Agent could not get context"
  fi

  section "6.3: Agent opens file for review"
  if nvim-remote edit "$test_file" 2>&1; then
    pass "Agent opened file for review"
  else
    fail "Agent failed to open file"
  fi

  sleep 0.3

  section "6.4: Agent searches for TODO items"
  nvim-remote search "TODO" >/dev/null 2>&1
  sleep 0.2

  local todo_line
  todo_line=$(nvim-remote status 2>&1 | grep "^Position:" | awk '{print $3}' | tr -d ',')

  if [[ "$todo_line" == "10" ]]; then
    pass "Agent found TODO at line 10"
  else
    fail "Agent expected TODO at line 10, found at line $todo_line"
  fi

  section "6.5: Agent navigates to function definition"
  nvim-remote goto 15 >/dev/null 2>&1
  sleep 0.2

  local func_line
  func_line=$(nvim-remote status 2>&1 | grep "^Position:" | awk '{print $3}' | tr -d ',')

  if [[ "$func_line" == "15" ]]; then
    pass "Agent navigated to function at line 15"
  else
    fail "Agent navigation failed, at line $func_line"
  fi

  section "6.6: Agent verifies final state"
  local final_status
  final_status=$(nvim-remote status 2>&1)

  local final_file
  final_file=$(echo "$final_status" | grep "^File:" | cut -d' ' -f2-)

  if [[ "$final_file" == "$test_file" ]]; then
    pass "Agent workflow complete - correct file open"
  else
    fail "Agent workflow error - wrong file open"
  fi

  # Cleanup
  rm -f "$test_file"
}

# Test 7: Socket Management
test_socket_management() {
  print_test "Socket Management"

  section "7.1: List all sockets with details"
  local list_output
  list_output=$(nvim-socket list 2>&1)

  if [[ $? -eq 0 ]]; then
    pass "Socket list retrieved"

    # Count sockets
    local count
    count=$(echo "$list_output" | tail -n +3 | wc -l | tr -d ' ')
    info "Total sockets: $count"
  else
    fail "Socket list failed"
  fi

  section "7.2: Get current pane socket"
  local current_pane
  current_pane=$(tmux display-message -p "#{pane_id}" | sed 's/^%//')

  local pane_socket
  pane_socket=$(nvim-socket find "$current_pane" 2>&1)

  # May or may not exist in current pane
  if [[ $? -eq 0 ]]; then
    pass "Current pane has Neovim: $pane_socket"
  else
    info "Current pane has no Neovim socket (expected for test pane)"
    pass "Socket find handles missing pane correctly"
  fi

  section "7.3: Find socket with explicit pane ID"
  # Get first available socket's pane ID
  local first_socket
  first_socket=$(nvim-socket list 2>&1 | tail -n +3 | head -1 | awk '{print $1}')

  if [[ -n "$first_socket" ]]; then
    local found_socket
    found_socket=$(nvim-socket find "$first_socket" 2>&1)

    if [[ $? -eq 0 ]]; then
      pass "Found socket for pane $first_socket"
    else
      fail "Could not find socket for known pane"
    fi
  else
    info "No sockets available to test explicit find"
  fi
}

# Main test runner
main() {
  echo "=========================================="
  echo "Neovim Remote Control Integration Tests"
  echo "=========================================="
  echo ""

  # Check prerequisites
  check_tmux
  check_neovim_instances

  info "Test environment:"
  info "  TMUX: ${TMUX:-not set}"
  info "  Session: $(tmux display-message -p '#{session_name}')"
  info "  Window: $(tmux display-message -p '#{window_index}')"
  info "  Pane: $(tmux display-message -p '#{pane_id}')"

  # Run all tests
  test_socket_discovery
  test_remote_status
  test_file_operations
  test_navigation
  test_search
  test_workflow
  test_socket_management

  # Print summary
  echo ""
  echo "=========================================="
  echo "INTEGRATION TEST SUMMARY"
  echo "=========================================="
  echo -e "Passed: ${GREEN}${TESTS_PASSED}${NC}"
  echo -e "Failed: ${RED}${TESTS_FAILED}${NC}"
  echo "Total:  $((TESTS_PASSED + TESTS_FAILED))"
  echo "=========================================="

  if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}All integration tests passed!${NC}"
    echo ""
    echo "The Neovim remote control system is working correctly:"
    echo "  ✓ Socket discovery (auto, list, find, show)"
    echo "  ✓ File operations (edit, open at line)"
    echo "  ✓ Navigation (goto)"
    echo "  ✓ Search (pattern matching)"
    echo "  ✓ Status queries"
    echo "  ✓ Complete agent workflows"
    exit 0
  else
    echo -e "${RED}Some integration tests failed${NC}"
    exit 1
  fi
}

# Execute if script is not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

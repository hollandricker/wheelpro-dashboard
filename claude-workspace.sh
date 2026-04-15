#!/bin/bash
# ============================================================
# WheelPro Multi-Directory Workspace Launcher
# ============================================================
# Launches Claude Code with access to all WheelPro directories
# at once using --add-dir.
#
# Usage:
#   ./claude-workspace.sh                  # Use default directories
#   ./claude-workspace.sh /path/a /path/b  # Use custom directories
#
# Setup:
#   1. Edit WHEELPRO_DIRS below to list your WheelPro directories
#   2. chmod +x claude-workspace.sh
#   3. Run from any WheelPro directory
# ============================================================

# Default WheelPro directories — edit these to match your setup
WHEELPRO_DIRS=(
  "$HOME/wheelpro-dashboard"
  "$HOME/wheelpro-backend"       # <-- change to your 2nd directory
  # "$HOME/wheelpro-api"          # <-- uncomment/add more as needed
)

# Override with command-line args if provided
if [ $# -gt 0 ]; then
  WHEELPRO_DIRS=("$@")
fi

# Determine the primary directory (current dir if it's in the list, else first entry)
PRIMARY_DIR=""
CURRENT_DIR="$(pwd)"
for dir in "${WHEELPRO_DIRS[@]}"; do
  resolved="$(cd "$dir" 2>/dev/null && pwd)"
  if [ "$resolved" = "$CURRENT_DIR" ]; then
    PRIMARY_DIR="$resolved"
    break
  fi
done
if [ -z "$PRIMARY_DIR" ]; then
  PRIMARY_DIR="${WHEELPRO_DIRS[0]}"
fi

# Build the --add-dir flags for all non-primary directories
ADD_DIR_FLAGS=()
for dir in "${WHEELPRO_DIRS[@]}"; do
  resolved="$(cd "$dir" 2>/dev/null && pwd)"
  if [ -z "$resolved" ]; then
    echo "Warning: Directory not found, skipping: $dir"
    continue
  fi
  if [ "$resolved" != "$(cd "$PRIMARY_DIR" 2>/dev/null && pwd)" ]; then
    ADD_DIR_FLAGS+=("--add-dir" "$resolved")
  fi
done

echo "Launching Claude Code workspace..."
echo "  Primary:    $PRIMARY_DIR"
for dir in "${ADD_DIR_FLAGS[@]}"; do
  [ "$dir" != "--add-dir" ] && echo "  Additional:  $dir"
done
echo ""

# Launch Claude Code
cd "$PRIMARY_DIR" && claude "${ADD_DIR_FLAGS[@]}" "$@"

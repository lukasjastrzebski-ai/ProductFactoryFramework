#!/bin/bash
# Generate Claude Code permissions based on planning artifacts
# Run after Stage 7 completion

set -e

OUTPUT_FILE=".claude/settings.local.json"
mkdir -p .claude

echo "Analyzing planning artifacts for required permissions..."

# Base permissions for all factory projects
BASE_PERMISSIONS=(
  # File operations (planning)
  "Bash(mkdir:*)"
  "Bash(cat:*)"
  "Bash(cp:*)"
  "Bash(mv:*)"
  "Bash(ls:*)"
  "Bash(echo:*)"
  "Bash(touch:*)"
  "Bash(head:*)"
  "Bash(tail:*)"
  "Bash(wc:*)"

  # Git operations
  "Bash(git add:*)"
  "Bash(git commit:*)"
  "Bash(git push:*)"
  "Bash(git pull:*)"
  "Bash(git status:*)"
  "Bash(git log:*)"
  "Bash(git diff:*)"
  "Bash(git branch:*)"
  "Bash(git checkout:*)"
  "Bash(git worktree:*)"
)

# Detect project type and add specific permissions
detect_project_permissions() {
  local permissions=()

  # Swift/iOS project
  if [ -f "Package.swift" ] || ls *.xcodeproj 2>/dev/null; then
    permissions+=(
      "Bash(xcodebuild:*)"
      "Bash(swift:*)"
      "Bash(xcrun:*)"
      "Bash(pod:*)"
    )
  fi

  # Node.js project
  if [ -f "package.json" ]; then
    permissions+=(
      "Bash(npm:*)"
      "Bash(npx:*)"
      "Bash(node:*)"
      "Bash(yarn:*)"
      "Bash(pnpm:*)"
    )
  fi

  # Python project
  if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    permissions+=(
      "Bash(python:*)"
      "Bash(python3:*)"
      "Bash(pip:*)"
      "Bash(pytest:*)"
    )
  fi

  # Go project
  if [ -f "go.mod" ]; then
    permissions+=(
      "Bash(go:*)"
    )
  fi

  # Rust project
  if [ -f "Cargo.toml" ]; then
    permissions+=(
      "Bash(cargo:*)"
      "Bash(rustc:*)"
    )
  fi

  echo "${permissions[@]}"
}

# Generate JSON
generate_json() {
  local all_permissions=("${BASE_PERMISSIONS[@]}")
  local project_permissions=($(detect_project_permissions))
  all_permissions+=("${project_permissions[@]}")

  echo "{"
  echo '  "permissions": {'
  echo '    "allow": ['

  local first=true
  for perm in "${all_permissions[@]}"; do
    if [ "$first" = true ]; then
      first=false
    else
      echo ","
    fi
    echo -n "      \"$perm\""
  done

  echo ""
  echo '    ]'
  echo '  }'
  echo "}"
}

# Write output
generate_json > "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE with $(grep -c '"Bash' "$OUTPUT_FILE") allowed commands"
echo ""
echo "Permissions include:"
echo "  - Base file operations (mkdir, cat, cp, ls, etc.)"
echo "  - Git operations (add, commit, push, etc.)"

if [ -f "Package.swift" ] || ls *.xcodeproj 2>/dev/null; then
  echo "  - Swift/iOS tools (xcodebuild, swift, xcrun)"
fi

if [ -f "package.json" ]; then
  echo "  - Node.js tools (npm, npx, node)"
fi

echo ""
echo "To apply: Restart Claude Code session"

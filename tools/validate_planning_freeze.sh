#!/usr/bin/env bash
set -e

if [ -f .factory/PLANNING_FROZEN ]; then
  echo "Planning freeze active. Validating changes..."

  git diff --name-only origin/main...HEAD | while read -r file; do
    case "$file" in
      specs/*|architecture/*|plan/*)
        echo "Planning file modified during freeze: $file"
        exit 1
        ;;
    esac
  done
fi

echo "Planning freeze validation passed."
#!/usr/bin/env bash
set -e

echo "Validating markdown links..."

grep -R "\.md" -n docs | while read -r line; do
  file=$(echo "$line" | cut -d: -f1)
  refs=$(grep -oE "\(([^)]+\.md)\)" "$file" | tr -d '()' || true)
  for ref in $refs; do
    if [ ! -f "$ref" ]; then
      echo "Broken reference: $file -> $ref"
      exit 1
    fi
  done
done

echo "Link validation passed."
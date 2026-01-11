#!/usr/bin/env bash
set -e

OUT="docs/signals/signal_snapshot_generated.md"
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "# Signal Snapshot" > $OUT
echo "" >> $OUT
echo "Generated at: $DATE" >> $OUT
echo "" >> $OUT

for f in signals/*.txt; do
  name=$(basename "$f")
  value=$(cat "$f")
  echo "## $name" >> $OUT
  echo "$value" >> $OUT
  echo "" >> $OUT
done

echo "Snapshot written to $OUT"
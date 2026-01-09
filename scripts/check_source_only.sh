#!/usr/bin/env bash
set -euo pipefail

offending=$(find versions -type f ! \( -name "*.c" -o -name "*.h" -o -name "*.md" \))
if [ -n "$offending" ]; then
  echo "ERROR: Non source-only files found under versions/:"
  echo "$offending"
  exit 1
fi

artifacts=$(find versions -type f \( -name "*.o" -o -name "*.a" -o -name "*.so" \))
if [ -n "$artifacts" ]; then
  echo "ERROR: Build artifacts found under versions/:"
  echo "$artifacts"
  exit 1
fi

echo "OK: versions/ is source-only (.c/.h/.md)"

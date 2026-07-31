#!/usr/bin/env bash
set -euo pipefail

if .buildkite/publish.sh --check; then
  .buildkite/deploy.sh
  .buildkite/publish.sh
else
  status=$?
  if [[ "$status" -eq 3 ]]; then
    echo "A newer emoji release already exists; skipping S3 and npm"
    exit 0
  fi
  exit "$status"
fi

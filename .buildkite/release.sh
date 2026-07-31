#!/usr/bin/env bash
set -euo pipefail

publish() {
  docker run --rm \
    --env BUILDKITE_BUILD_NUMBER \
    --env NPM_TOKEN \
    --volume "$PWD:/work" \
    --workdir /work \
    node:22 \
    .buildkite/publish.sh "$@"
}

if publish --check; then
  .buildkite/deploy.sh
  publish
else
  status=$?
  if [[ "$status" -eq 3 ]]; then
    echo "A newer emoji release already exists; skipping S3 and npm"
    exit 0
  fi
  exit "$status"
fi

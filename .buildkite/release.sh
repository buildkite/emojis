#!/usr/bin/env bash
set -euo pipefail

.buildkite/deploy.sh

docker run --rm \
  --env BUILDKITE_BUILD_NUMBER \
  --env NPM_TOKEN \
  --volume "$PWD:/work" \
  --workdir /work \
  node:22 \
  .buildkite/publish.sh

#!/usr/bin/env bash
set -euo pipefail

: "${BUILDKITE_BUILD_NUMBER:?BUILDKITE_BUILD_NUMBER is required}"
: "${NPM_TOKEN:?NPM_TOKEN is required}"

user_config="$(mktemp)"
trap 'rm -f "$user_config"' EXIT
printf '//registry.npmjs.org/:_authToken=%s\n' "$NPM_TOKEN" > "$user_config"
export NPM_CONFIG_USERCONFIG="$user_config"

if current_version="$(npm view "@buildkite/emojis" version 2>&1)"; then
  version="2.0.${BUILDKITE_BUILD_NUMBER}"
elif [[ "$current_version" == *"E404"* ]]; then
  version="$(node -p "require('./package.json').version")"
else
  printf '%s\n' "$current_version" >&2
  exit 1
fi

if npm view "@buildkite/emojis@${version}" version >/dev/null 2>&1; then
  echo "@buildkite/emojis@${version} is already published"
  exit 0
fi

if [ "$(node -p "require('./package.json').version")" != "$version" ]; then
  npm version "$version" --no-git-tag-version
fi
npm publish

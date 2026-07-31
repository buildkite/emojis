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
  is_newer="$(node -e '
    const [candidate, current] = process.argv.slice(1).map((version) => version.split(".").map(Number));
    const comparison = candidate.reduce((result, part, index) => result || Math.sign(part - (current[index] ?? 0)), 0);
    process.stdout.write(comparison > 0 ? "true" : "false");
  ' "$version" "$current_version")"
  if [ "$is_newer" != "true" ]; then
    echo "@buildkite/emojis@${current_version} is newer than or equal to ${version}"
    exit 0
  fi
elif [[ "$current_version" == *"E404"* ]]; then
  # Bootstrap the new scope at the source version so consumers can prepare
  # lockfiles before the first main-branch publication.
  version="$(node -p "require('./package.json').version")"
else
  printf '%s\n' "$current_version" >&2
  exit 1
fi

if [ "$(node -p "require('./package.json').version")" != "$version" ]; then
  npm version "$version" --no-git-tag-version
fi
npm publish

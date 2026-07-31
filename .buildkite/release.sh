#!/usr/bin/env bash
set -euo pipefail

: "${BUILDKITE_BUILD_NUMBER:?BUILDKITE_BUILD_NUMBER is required}"

# Drop the token from the environment before S3 sync; restore only for publish.
npm_token="${NPM_TOKEN:-}"
unset NPM_TOKEN

git fetch --quiet origin main
if [[ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]]; then
  echo "Skipping release: HEAD is not tip of origin/main"
  exit 0
fi

# CDN sync is independent of npm registry health and auth.
.buildkite/deploy.sh

package_version="$(node -p "require('./package.json').version")"
version_stdout="$(mktemp)"
version_stderr="$(mktemp)"
user_config=""
cleanup() {
  rm -f "$version_stdout" "$version_stderr"
  if [[ -n "$user_config" ]]; then
    rm -f "$user_config"
  fi
}
trap cleanup EXIT

set +e
npm view "@buildkite/emojis" version >"$version_stdout" 2>"$version_stderr"
view_status=$?
set -e

if [[ "$view_status" -eq 0 ]]; then
  current_version="$(tr -d '[:space:]' <"$version_stdout")"
  version="${package_version%.*}.${BUILDKITE_BUILD_NUMBER}"
  is_newer="$(node -e '
    const [candidate, current] = process.argv.slice(1).map((version) => version.split(".").map(Number));
    const comparison = candidate.reduce((result, part, index) => result || Math.sign(part - (current[index] ?? 0)), 0);
    process.stdout.write(comparison > 0 ? "true" : "false");
  ' "$version" "$current_version")"
  if [[ "$is_newer" != "true" ]]; then
    echo "@buildkite/emojis@${current_version} is newer than or equal to ${version}; skipping npm publish"
    exit 0
  fi
elif grep -q E404 "$version_stderr"; then
  # Bootstrap the new scope at the source version so consumers can prepare
  # lockfiles before the first main-branch publication.
  version="$package_version"
else
  cat "$version_stderr" >&2
  exit 1
fi

: "${npm_token:?NPM_TOKEN is required}"
user_config="$(mktemp)"
printf '//registry.npmjs.org/:_authToken=%s\n' "$npm_token" > "$user_config"
export NPM_CONFIG_USERCONFIG="$user_config"
unset npm_token

if [[ "$package_version" != "$version" ]]; then
  npm version "$version" --no-git-tag-version
fi
npm publish

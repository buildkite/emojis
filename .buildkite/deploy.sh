#!/bin/bash
set -e

echo "--- :smile: Checking this works!"

# Check if the edited files are only img-buildkite-64.json and README.md
edited_files=$(git diff --name-only main)
echo "Edited files: $edited_files"

# Determine if it's an emoji PR
emoji_pr=true
for file in $edited_files; do
  if [[ "$file" != "img-buildkite-64.json" && "$file" != "README.md" && "$file" != img-buildkite-64/* ]]; then
    emoji_pr=false
    break
  fi
done

if [[ "$emoji_pr" == true ]]; then
  echo "This is an emoji PR."
  # Validate img-buildkite-64.json
  if [[ "$edited_files" == *"img-buildkite-64.json"* ]]; then
    if ! jq empty img-buildkite-64.json >/dev/null 2>&1; then
      echo "Error: img-buildkite-64.json is not valid JSON."
      exit 1
    fi
  fi

  # Check if the README.md contains the correct structure for the emoji
  if [[ "$edited_files" == *"README.md"* ]]; then
    while IFS= read -r line; do
      if [[ "$line" =~ ^\<img\ src=\"img-buildkite-64/.*\"\ width=\"20\"\ height=\"20\"\ alt=\".*\"/\>\ \|\ \`.*\`$ ]]; then
        echo "README.md contains the correct structure for the emoji."
      else
        echo "Error: README.md does not contain the correct structure for the emoji."
        exit 1
      fi
    done < README.md
  fi
  # Check if the images in img-buildkite-64 are 64x64 px PNGs
  for file in $edited_files; do
    if [[ "$file" == img-buildkite-64/* ]]; then
      dimensions=$(identify -format "%wx%h" "$file")
      if [[ "$dimensions" != "64x64" ]]; then
        echo "Error: Image $file is not 64x64 pixels."
        exit 1
      fi
      file_type=$(file --mime-type -b "$file")
      if [[ "$file_type" != "image/png" ]]; then
        echo "Error: Image $file is not a PNG file."
        exit 1
      fi
    fi
  done
else
  echo "Error: Only img-buildkite-64.json, README.md, and files in img-buildkite-64 directory are allowed to be edited."
  # exit 1
fi

echo "All done! 💪"

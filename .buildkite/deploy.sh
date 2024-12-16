#!/bin/bash
set -e

echo "--- :smile: Checking this works!"
# git diff HEAD~
# git diff --name-only HEAD

# Check if the edited files are only img-buildkite-64.json and README.md
edited_files=$(git diff --name-only HEAD)
echo "Edited files: $edited_files"
for file in $edited_files; do
  if [[ "$file" != "img-buildkite-64.json" && "$file" != "README.md" && "$file" != img-buildkite-64/* ]]; then
    echo "Error: Only img-buildkite-64.json, README.md, and files in img-buildkite-64 directory are allowed to be edited."
    # exit 1
  fi
done
# Check if the images in img-buildkite-64 are 64x64 px PNGs
for file in $edited_files; do
  if [[ "$file" == img-buildkite-64/* ]]; then
    dimensions=$(identify -format "%wx%h" "$file")
    if [[ "$dimensions" != "64x64" ]]; then
      echo "Error: Image $file is not 64x64 pixels."
      # exit 1
    fi
    file_type=$(file --mime-type -b "$file")
    if [[ "$file_type" != "image/png" ]]; then
      echo "Error: Image $file is not a PNG file."
      # exit 1
    fi
  fi
done

echo "All done! 💪"

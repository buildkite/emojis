#!/bin/bash
set -e

echo "--- :s3: Deploying emojis to $S3_BUCKET_PATH"

s3cmd put -P --recursive --verbose --force --no-preserve "img-apple-64" "$S3_BUCKET_PATH"
s3cmd put -P --recursive --verbose --force --no-preserve "img-buildkite-64" "$S3_BUCKET_PATH"

echo "All done! 💪"

#!/bin/bash
set -e

echo "--- :s3: Deploying emojis to $S3_BUCKET_PATH"

aws s3 sync --region "us-east-1" --acl "public-read" "img-apple-64" "$S3_BUCKET_PATH/img-apple-64"
aws s3 sync --region "us-east-1" --acl "public-read" "img-buildkite-64" "$S3_BUCKET_PATH/img-buildkite-64"

echo "All done! 💪"

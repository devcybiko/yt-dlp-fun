#!/bin/bash -v
set -e

# Source the environment variables
if [[ ! -f "variables.env" ]]; then
  echo "Error: variables.env file not found. Please create it before running this script."
  exit 1
fi
source "variables.env"

delete-from-source.sh
yt-download.sh
copy-to-plex.sh
split-audios.sh
upload-files-to-s3.sh
upload-rss-feed-to-s3.sh

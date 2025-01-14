#!/bin/bash
# Variables for the podcast script
if [ -z "${POETRY_HOME+x}" ]; then
  echo "Error: POETRY_HOME is not set."
  echo "be sure to SOURCE ./scripts/source.me"
  exit 1
fi

# Source the environment variables
if [[ ! -f "variables.env" ]]; then
  echo "Error: variables.env file not found. Please create it before running this script."
  exit 1
fi
source "variables.env"

should_stop=false

handle_sigint() {
  echo -e "\nCtrl+C detected. Stopping script..."
  should_stop=true
}
trap handle_sigint SIGINT

mkdir -p "$video_dir"

while IFS= read -r line || [[ -n "$line" ]]; do
  IFS=',' read -ra fields <<< "$line"

  if $should_stop; then
    echo "Processing stopped."
    break
  fi

  # Skip empty lines or lines starting with '#'
  [[ -z "$line" || "$line" == \#* ]] && continue

  channel_id="${fields[0]}"    # First field
  channel_url="${fields[1]}"     # Second field
  channel_title="${fields[2]}"
  channel_title="${channel_title//[^a-zA-Z0-9]/_}"

  [[ "$channel_id" == "Channel Id" ]] && continue

  echo "Channel ID: $channel_id"
  echo "Channel URL: $channel_url"
  echo "Channel Title: $channel_title"

  if [[ "$channel_id" == "" || "$channel_url" == "" || "$channel_title" == "" ]]; then
    echo "Skipping ... Bad entry..."
    continue
  fi

  mkdir -p "$video_dir/$channel_title"

  feed="https://www.youtube.com/feeds/videos.xml?channel_id=$channel_id"
  echo "FEED: $feed"

  yt-dlp \
    --dateafter now-7days \
    --download-archive "$archive_file" \
    --output "./$video_dir/$channel_title/%(title)s.%(ext)s" \
    --no-post-overwrites \
    --no-mtime \
    --remux-video mp4 \
    --quiet \
    --match-filter "duration <= $duration_min & duration <= $duration_max" \
    -- "$feed"

  echo "--------------------------"
done < "$csv_file"

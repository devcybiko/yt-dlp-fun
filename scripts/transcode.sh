#!/bin/bash

# Source the environment variables
if [[ ! -f "variables.env" ]]; then
  echo "Error: variables.env file not found. Please create it before running this script."
  exit 1
fi
source "variables.env"

input="$1"

if [[ "$input" == "" ]]; then
  echo "Usage: $0 <input_file>"
  exit 1
fi

output=`dirname "$input"`/`basename "$input" .mp4`"-1.5x.mp4"
echo $input $output
# Quality Tuning: Adjust the -crf value for higher or lower quality (e.g., -crf 18 for higher quality).
ffmpeg -i "$input" \
    -filter:v "setpts=PTS/1.5" -filter:a "atempo=1.5" \
    -c:v h264_videotoolbox -b:v 5000k \
    -c:a aac -b:a 192k \
    "$output"
status=$?
if [[ $status -eq 0 ]]; then
  echo "Removing $input"
  rm "$input"
fi

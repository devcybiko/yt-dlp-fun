#!/bin/bash

# Source the environment variables
if [[ ! -f "variables.env" ]]; then
  echo "Error: variables.env file not found. Please create it before running this script."
  exit 1
fi
source "variables.env"

if [[ "$transcode" == "true" ]]; then
  # Define source and destination directories
  # NOTE: PUT A SLASH AT THE END OF THE SOURCE DIRECTORY
  SOURCE="./$video_dir"
  
  # Transcode videos
  find "$SOURCE" -type f -name "*.mp4" -ls -exec transcode.sh "{}" \;
fi
#!/bin/bash

# Source the environment variables
if [[ ! -f "variables.env" ]]; then
  echo "Error: variables.env file not found. Please create it before running this script."
  exit 1
fi
source "variables.env"

# Create the output directory if it doesn't exist
mkdir -p "$audio_dir"

# Clear the log file if it exists
> "$error_log"

# Function to handle SIGINT (Ctrl+C)
handle_sigint() {
  echo -e "\nCtrl+C detected. Exiting immediately..."
  # Kill all child processes (e.g., ffmpeg) and exit
  kill 0
  exit 1
}

# Set trap for SIGINT
trap handle_sigint SIGINT

# Recursively process all video files
find "$video_dir" -type f | while IFS= read -r video_file; do
  # Stop processing if Ctrl+C was detected
  if [[ $? -ne 0 ]]; then
    echo "Processing stopped by user."
    exit 1
  fi

  # Extract the relative path of the video file from the base directory
  relative_path="${video_file#$video_dir/}"

  # Extract the directory structure and base name
  channel_dir=$(dirname "$relative_path")
  base_name=$(basename "${video_file%.*}")

  # Replace special characters in the base name with underscores
  sanitized_base_name="${base_name//[^a-zA-Z0-9]/_}"

  # Collapse consecutive underscores into a single underscore
  sanitized_base_name=$(echo "$sanitized_base_name" | sed -E 's/_+/_/g')

  # Create the corresponding output directory in audios
  mkdir -p "$audio_dir/$channel_dir"

  # Set the output audio file path with sanitized name
  audio_file="$audio_dir/$channel_dir/$sanitized_base_name.mp3"

  # Skip if the audio file already exists
  if [[ -f "$audio_file" ]]; then
    echo "Skipping existing file: $audio_file"
    continue
  fi

  # Extract audio using ffmpeg in a subshell
  echo "Extracting audio from $video_file to $audio_file..."
  (
    ffmpeg -i "$video_file" -q:a 0 -map a -y "$audio_file" 2>>"$error_log"
  ) &

  # Wait for the child process to finish
  wait $!

  # Check if the child process exited due to a signal
  status=$?
  if [[ $status -eq 130 ]]; then
    echo "Terminated by Ctrl+C during ffmpeg execution."
    exit 1
  elif [[ $status -ne 0 ]]; then
    echo "Error processing $video_file. See $error_log for details."
    continue
  fi

  echo "Finished extracting: $audio_file"
done

echo "All audio files extracted to $audio_dir. Errors, if any, are logged in $error_log."

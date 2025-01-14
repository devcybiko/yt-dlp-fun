#!/bin/bash
# Source the environment variables
if [[ ! -f "variables.env" ]]; then
  echo "Error: variables.env file not found. Please create it before running this script."
  exit 1
fi
source "variables.env"

# Define source and destination directories
# NOTE: PUT A SLASH AT THE END OF THE SOURCE DIRECTORY
SOURCE="$video_dir/"
DESTINATION="$plex/videos/"
# DRY_RUN=--dry-run # Uncomment this line to test the script without copying files

# rsync
# -a (archive): Preserves permissions, timestamps, symbolic links, etc.
# -v (verbose): Displays details about the operation.
# -z (compress): Compresses data during transfer for faster performance.
# --delete: Removes files from the destination that are not in the source.
# --ignore-existing: Skips files that already exist in the destination.
# --dry-run: Simulates the operation without making changes.
# --progress: Displays transfer progress for each file.

find "$DESTINATION" -type d -empty -delete

# SOURCE -> DESTINATION
rsync -av $DRY_RUN --delete --ignore-existing "$SOURCE" "$DESTINATION"

counts.sh
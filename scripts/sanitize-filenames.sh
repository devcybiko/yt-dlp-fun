#!/bin/bash

# Define the target directory (current directory by default)
TARGET_DIR="${1:-.}"

# Function to recursively process files and directories
process_directory() {
  local dir="$1"
  for entry in "$dir"/*; do
    # Skip if no files exist in the directory
    [ -e "$entry" ] || continue

    # Process directories recursively
    if [ -d "$entry" ]; then
      process_directory "$entry"
    fi

    # Get the base name and directory of the current entry
    local base_name=$(basename "$entry")
    local dir_name=$(dirname "$entry")

    # Replace multiple underscores with a single underscore
    local sanitized_base_name=$(echo "$base_name" | sed -E 's/_+/_/g')

    # Rename the file or folder if the name has changed
    if [ "$base_name" != "$sanitized_base_name" ]; then
      echo moving $base_name to $sanitized_base_name
      mv -v "$entry" "$dir_name/$sanitized_base_name"
    fi
  done
}

# Start processing from the target directory
process_directory "$TARGET_DIR"

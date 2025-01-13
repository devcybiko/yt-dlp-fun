#!/bin/bash

# Source the environment variables
if [[ ! -f "variables.env" ]]; then
  echo "Error: variables.env file not found. Please create it before running this script."
  exit 1
fi
source "variables.env"

# Ensure AWS CLI is installed
if ! command -v aws &> /dev/null; then
  echo "AWS CLI not found. Please install it before running this script."
  exit 1
fi

# Validate artwork file
if [[ ! -f "$artwork_file" ]]; then
  echo "Error: $artwork_file not found. Please check variables.env."
  exit 1
fi

# Upload artwork file
echo "Uploading artwork to S3..."
aws s3 cp "$artwork_file" "s3://${s3_bucket}/${s3_folder}/artwork.jpg" --profile "$aws_profile" || {
  echo "Error: Failed to upload artwork.jpg"
  exit 1
}

# Upload audio files to S3 without ACLs
upload_files_to_s3() {
  echo "Uploading audio files to S3..."
  find "$audio_dir" -type f -name "*.mp3" | while IFS= read -r file; do
    file_name=$(basename "$file")
    s3_path="${s3_folder}/${file_name}"
    echo "Uploading $file_name to ${s3_path}..."
    if ! aws s3 cp "$file" "s3://${s3_bucket}/${s3_path}" --profile "$aws_profile"; then
      echo "Error: Failed to upload $file_name" >&2
      exit 1
    fi
  done
}

# Log output
exec > >(tee -a "$log_file") 2>&1

# Main execution
upload_files_to_s3
echo "File Upload complete!"
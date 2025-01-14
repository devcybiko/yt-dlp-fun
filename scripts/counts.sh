# Source the environment variables
if [[ ! -f "variables.env" ]]; then
  echo "Error: variables.env file not found. Please create it before running this script."
  exit 1
fi
source "variables.env"

SOURCE="$video_dir"
DESTINATION="$plex/videos/"
AUDIOS="$audio_dir"

echo `find $SOURCE -type f  | wc -l` in $SOURCE
echo `find $DESTINATION -type f  | wc -l` in $DESTINATION
echo `find $AUDIOS -type f  | wc -l` in $AUDIOS

podcast_count=`aws s3 ls "s3://${s3_bucket}/${s3_folder}/" | wc -l`
podcast_counts=$((podcast_counts - 2)) # remove rss.xml and artwork.jpg
echo $podcast_count in s3://${s3_bucket}/${s3_folder}/

echo ""

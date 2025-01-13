#!/bin/bash
set -e
yt-download.sh
split-audios.sh
upload-files-to-s3.sh
upload_rss_feed_to_s3.sh

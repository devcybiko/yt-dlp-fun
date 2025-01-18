#!/bin/bash

podcast=$1

cd ~/git/yt-dtp-fun
source ./scripts/source.me
cd ./podcasts/$podcast
all.sh

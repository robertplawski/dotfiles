#!/bin/bash

# Base directory (your home)
BASE_DIR="$HOME"

# Array of directories to create
dirs=(
  "bin"
  "code/personal"
  "code/work"
  "code/experiments"
  "code/archived"
  "docs/school"
  "docs/work"
  "docs/personal"
  "media/pictures/memes"
  "media/pictures/wallpapers"
  "media/pictures/camera"
  "music"
  "videos"
  "downloads"
)

# Create directories
echo "Creating directories under $BASE_DIR..."
for dir in "${dirs[@]}"; do
  mkdir -p "$BASE_DIR/$dir"
  echo "Created: $BASE_DIR/$dir"
done

echo "All directories created!"


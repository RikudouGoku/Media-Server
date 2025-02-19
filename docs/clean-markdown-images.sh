#!/bin/bash

# clean-markdown-images.sh

# Default paths
IMAGE_PATH="./images"
MARKDOWN_PATH="."
UNUSED_PATH="./unused_images_$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false

# Function to show usage
usage() {
    echo "Usage: $0 [-i IMAGE_PATH] [-m MARKDOWN_PATH] [-o OUTPUT_PATH] [-d]"
    echo "  -i : Path to image directory (default: ./images)"
    echo "  -m : Path to markdown directory (default: current directory)"
    echo "  -o : Path for unused images (default: ./unused_images_TIMESTAMP)"
    echo "  -d : Dry run (show what would be moved)"
    exit 1
}

# Parse command line arguments
while getopts "i:m:o:d" opt; do
    case $opt in
        i) IMAGE_PATH="$OPTARG" ;;
        m) MARKDOWN_PATH="$OPTARG" ;;
        o) UNUSED_PATH="$OPTARG" ;;
        d) DRY_RUN=true ;;
        ?) usage ;;
    esac
done

# Check if directories exist
if [ ! -d "$IMAGE_PATH" ]; then
    echo "Error: Image directory '$IMAGE_PATH' not found"
    exit 1
fi

if [ ! -d "$MARKDOWN_PATH" ]; then
    echo "Error: Markdown directory '$MARKDOWN_PATH' not found"
    exit 1
fi

# Create unused images directory
if [ "$DRY_RUN" = false ]; then
    mkdir -p "$UNUSED_PATH"
    echo "Created directory for unused images: $UNUSED_PATH"
fi

# Initialize counters
total_images=0
unused_count=0

# Process each image
find "$IMAGE_PATH" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.svg" \) | while read image; do
    ((total_images++))
    filename=$(basename "$image")
    
    # Check if image is used in any markdown file
    if ! grep -r -l -F "$filename" "$MARKDOWN_PATH" >/dev/null 2>&1; then
        ((unused_count++))
        echo "Unused image found: $filename"
        
        if [ "$DRY_RUN" = true ]; then
            echo "  Would move: $image -> $UNUSED_PATH/"
        else
            mv "$image" "$UNUSED_PATH/"
            echo "  -> Moved to: $UNUSED_PATH/$filename"
        fi
    fi
done

# Print summary
echo -e "\nSummary:"
echo "Total images processed: $total_images"
echo "Unused images found: $unused_count"
if [ "$DRY_RUN" = false ]; then
    echo "Moved images location: $UNUSED_PATH"
fi

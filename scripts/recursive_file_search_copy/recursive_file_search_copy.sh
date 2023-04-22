#!/bin/bash

# Check for correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <file extension> <input directory> <output directory>"
    exit 1
fi

# Assign args
file_ext=$1
input_dir=$2
output_dir=$3

# Check if input dir exists
if [ ! -d "$input_dir" ]; then
    echo "Error: Input directory does not exist"
    exit 1
fi

# Check if output dir exists
if [ ! -d "$output_dir" ]; then
    echo "Error: Output directory does not exist"
    exit 1
fi

# Recursively search for files with the specified extension in the input directory
for file in $(find "$input_dir" -type f -name "*.$file_ext"); do
    # Get the filename without the path
    filename=$(basename "$file")

    # Check if the file already exists in the output directory
    if [ -f "$output_dir/$filename" ]; then
        echo "Skipping $filename - already exists in output directory"
    else
        # Copy the file to the output directory and log the action
        cp "$file" "$output_dir/$filename"
        echo "Copied $filename to output directory"
    fi
done

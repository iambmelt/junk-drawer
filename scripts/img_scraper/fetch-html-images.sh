#!/bin/bash

# Set the URL to fetch
url="https://www.example.com"

# Fetch the content using curl
content=$(curl -s "$url")

# Test if the content contains HTML
if [[ "$content" == *"<html"* ]]; then
    echo "The content of $url contains HTML"

    # Download any images contained within the document
    image_urls=$(echo "$content" | grep -oE "src=\"[^\"]+\"" | sed -E 's/src="([^"]+)"/\1/g')

    for image_url in $image_urls; do
        echo "Downloading image: $image_url"
        curl -s "$image_url" -o "$(basename $image_url)"
    done
else
    echo "The content of $url does not contain HTML"
fi

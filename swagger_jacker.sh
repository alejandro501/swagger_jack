#!/bin/bash

# File containing the list of Swagger URLs
input_file="swagger_endpoints.txt"

# Check if the input file exists
if [[ ! -f $input_file ]]; then
    echo "File not found: $input_file"
    exit 1
fi

# Read the URLs from the file and loop through each one
while IFS= read -r url; do
    echo "Running sj automate for: $url"
    sj automate -u "$url"
    
    echo "Generating commands for manual testing for: $url"
    sj prepare -u "$url"
    
    echo "Listing endpoints for: $url"
    sj endpoints -u "$url"
done < "$input_file"

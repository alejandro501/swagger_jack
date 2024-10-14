#!/bin/bash

input_file="swagger_endpoints.txt"
output_file="$HOME/hack/resources/wordlists/swagger-jacker-api-wild.txt"

# Check for the --tor flag
USE_TOR=false
if [[ "$1" == "--tor" ]]; then
    USE_TOR=true
    # Set proxy environment variables to use Tor (SOCKS5 proxy)
    export https_proxy=socks5://127.0.0.1:9050
    export http_proxy=socks5://127.0.0.1:9050
    echo "Using Tor for swagger_jacker operations..."
fi

# Check if the input file exists
if [[ ! -f $input_file ]]; then
    echo "File not found: $input_file"
    exit 1
fi

# Check if the output file exists, if not create it
if [[ ! -f $output_file ]]; then
    echo "Output file not found: $output_file. Creating it."
    touch "$output_file"
else
    echo "Output file exists: $output_file. Appending new endpoints."
fi

while IFS= read -r url; do
    echo "Running sj automate for: $url"
    sj automate -u "$url" --outfile swagger_jacker.json

     sj automate -u "$url" --outfile swagger_brute.json

    echo "Listing endpoints for: $url"
    sj endpoints -u "$url" | anew "$output_file"

done < "$input_file"

# Unset proxy variables after completion if used
if [[ "$USE_TOR" == true ]]; then
    unset https_proxy http_proxy
fi

echo "New endpoints appended to $output_file"

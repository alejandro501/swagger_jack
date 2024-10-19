#!/bin/bash

input_file="swagger_endpoints.txt"
output_file="$HOME/hack/resources/wordlists/swagger-jacker-api-wild.txt"

# Determine if running in VPS mode
if [[ "$1" == "--vps" ]]; then
    GOBIN="/root/go/bin"
    SJ_CMD="$GOBIN/sj"
else
    SJ_CMD="sj"
fi

# Check for the --tor flag
USE_TOR=false
if [[ "$2" == "--tor" ]]; then
    USE_TOR=true
    export https_proxy=socks5://127.0.0.1:9050
    export http_proxy=socks5://127.0.0.1:9050
    echo "Using Tor for swagger_jacker operations..."
fi

if [[ ! -f $input_file ]]; then
    echo "File not found: $input_file"
    exit 1
fi

if [[ ! -f $output_file ]]; then
    echo "Output file not found: $output_file. Creating it."
    touch "$output_file"
else
    echo "Output file exists: $output_file. Appending new endpoints."
fi

while IFS= read -r url; do
    echo "Running sj automate for: $url"
    "$SJ_CMD" automate -u "$url" --outfile swagger_jacker.json

    "$SJ_CMD" automate -u "$url" --outfile swagger_brute.json

    echo "Listing endpoints for: $url"
    "$SJ_CMD" endpoints -u "$url" | anew "$output_file"
done < "$input_file"

if [[ "$USE_TOR" == true ]]; then
    unset https_proxy http_proxy
fi

echo "New endpoints appended to $output_file"

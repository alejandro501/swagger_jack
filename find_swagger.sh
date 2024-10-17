#!/bin/bash

SWAGGER_TEMPLATE="$HOME/nuclei-templates/http/exposures/apis/swagger-api.yaml"
DOMAINS_FILE="domains.txt"
MASTER_OUTPUT_FILE="nuclei_swagger_scan.txt"
URL_FILE=" temp_swagger_endpoints.txt"
FINAL_URL_FILE="swagger_endpoints.txt"
USE_TOR=false
GOBIN=""

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --input) 
            DOMAINS_FILE="$2"
            shift 2
            ;;
        --tor) 
            USE_TOR=true
            shift
            ;;
        --vps)
            SWAGGER_TEMPLATE="/root/hack/nuclei-templates/http/exposures/apis/swagger-api.yaml"
            GOBIN="/root/go/bin"
            shift
            ;;
        *) 
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done

if [ ! -f "$DOMAINS_FILE" ]; then
    echo "Domains file not found: $DOMAINS_FILE"
    exit 1
fi

if [[ "$USE_TOR" == true ]]; then
    export https_proxy=socks5://127.0.0.1:9050
    export http_proxy=socks5://127.0.0.1:9050
    echo "Using Tor for Nuclei scans..."
fi

> "$MASTER_OUTPUT_FILE"  # Clear master output file
> "$URL_FILE"            # Clear URL file

if [[ -n "$GOBIN" ]]; then
    NUCLEI_CMD="${GOBIN}/nuclei"
else
    NUCLEI_CMD="nuclei"
fi

# Split the domains file into chunks of 5001 lines
split -l 5001 "$DOMAINS_FILE" domains_chunk_

chunk_number=1  # Initialize chunk counter

# Process each chunk
for chunk in domains_chunk_*; do
    echo "Processing chunk: $chunk"

    # Output file for current chunk
    CHUNK_OUTPUT_FILE="${MASTER_OUTPUT_FILE}_${chunk_number}"

    # Clear the chunk output file
    > "$CHUNK_OUTPUT_FILE"

    while IFS= read -r domain; do
        domain="${domain%/}"

        if [[ $domain != http* ]]; then
            domain="https://$domain"
        fi

        echo "Checking $domain"
        "$NUCLEI_CMD" -list "$chunk" -t "$SWAGGER_TEMPLATE" -o "$CHUNK_OUTPUT_FILE"
        
    done < "$chunk"

    # Append the URLs found in the current chunk to the master URL file
    grep -oP '(?<=info] ).*(?= \[)' "$CHUNK_OUTPUT_FILE" >> "$URL_FILE"

    # Clean up the chunk output file after processing
    rm "$CHUNK_OUTPUT_FILE"

    # Increment the chunk counter
    ((chunk_number++))
    
    # Optionally, remove the chunk file after processing
    rm "$chunk"
done

# Clean up any remaining chunk files
rm domains_chunk_*

# Sort and get unique URLs, saving to the final output file
sort -u "$URL_FILE" -o "$FINAL_URL_FILE"
rm $URL_FILE

if [[ "$USE_TOR" == true ]]; then
    unset https_proxy http_proxy
fi

echo "Scan complete. Unique URLs saved to $FINAL_URL_FILE."

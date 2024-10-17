#!/bin/bash

SWAGGER_TEMPLATE="$HOME/nuclei-templates/http/exposures/apis/swagger-api.yaml"
DOMAINS_FILE="domains.txt"
OUTPUT_FILE="nuclei_swagger_scan.txt"
URL_FILE="swagger_endpoints.txt"
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

> "$OUTPUT_FILE"
> "$URL_FILE"

if [[ -n "$GOBIN" ]]; then
    NUCLEI_CMD="${GOBIN}/nuclei"
else
    NUCLEI_CMD="nuclei"
fi

# Split the domains file into chunks of 5001 lines
split -l 5001 "$DOMAINS_FILE" domains_chunk_

# Process each chunk
for chunk in domains_chunk_*; do
    echo "Processing chunk: $chunk"

    while IFS= read -r domain; do
        domain="${domain%/}"

        if [[ $domain != http* ]]; then
            domain="https://$domain"
        fi

        echo "Checking $domain"
        "$NUCLEI_CMD" -list "$chunk" -t "$SWAGGER_TEMPLATE" -o "$OUTPUT_FILE"
        
    done < "$chunk"

    # Optionally, remove the chunk file after processing
    rm "$chunk"
done

grep -oP '(?<=info] ).*(?= \[)' "$OUTPUT_FILE" > "$URL_FILE"

if [[ "$USE_TOR" == true ]]; then
    unset https_proxy http_proxy
fi

echo "Scan complete. URLs saved to $URL_FILE."

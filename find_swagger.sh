#!/bin/bash

# Path to the Nuclei template for Swagger API
SWAGGER_TEMPLATE="$HOME/nuclei-templates/http/exposures/apis/swagger-api.yaml"

# default file init
DOMAINS_FILE="domains.txt"
OUTPUT_FILE="nuclei_swagger_scan.txt"
URL_FILE="swagger_endpoints.txt"

# args
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
        *) 
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done

# Check if the domains file exists
if [ ! -f "$DOMAINS_FILE" ]; then
    echo "Domains file not found: $DOMAINS_FILE"
    exit 1
fi

# Set proxy environment variables to use Tor (SOCKS5 proxy) if --tor is specified
if [[ "$USE_TOR" == true ]]; then
    export https_proxy=socks5://127.0.0.1:9050
    export http_proxy=socks5://127.0.0.1:9050
    echo "Using Tor for Nuclei scans..."
fi

# Create or clear the output files
> "$OUTPUT_FILE"
> "$URL_FILE"

while IFS= read -r domain; do
    domain="${domain%/}"

    if [[ $domain != http* ]]; then
        domain="https://$domain"
    fi

    echo "Checking $domain"

    nuclei -list "$DOMAINS_FILE" -t "$SWAGGER_TEMPLATE" -o "$OUTPUT_FILE" -rate-limit-duration 5 -max-host-error 10
    
done < "$DOMAINS_FILE"

# Extract URLs from the scan results and save to swagger_endpoints.txt
grep -oP '(?<=info] ).*(?= \[)' "$OUTPUT_FILE" > "$URL_FILE"

# Unset proxy variables after completion if used
if [[ "$USE_TOR" == true ]]; then
    unset https_proxy http_proxy
fi

echo "Scan complete. URLs saved to $URL_FILE."

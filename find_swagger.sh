#!/bin/bash

# Path to the Nuclei template for Swagger API
SWAGGER_TEMPLATE="/home/rojo/nuclei-templates/http/exposures/apis/swagger-api.yaml"

# Default domains file
DOMAINS_FILE="domains.txt"
OUTPUT_FILE="nuclei_swagger_scan.txt"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --input) 
            DOMAINS_FILE="$2"
            shift 2 # Shift past the argument and its value
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

# Create or clear the output file
> "$OUTPUT_FILE"

# Loop through each domain in the provided file
while IFS= read -r domain; do
    # Remove any trailing slashes
    domain="${domain%/}"

    # Check if the domain includes a protocol
    if [[ $domain != http* ]]; then
        domain="https://$domain"
    fi

    echo "Checking $domain"

    # Run Nuclei
    nuclei -list "$DOMAINS_FILE" -t "$SWAGGER_TEMPLATE" -o "$OUTPUT_FILE" -rate-limit-duration 5 -max-host-error 10
    
done < "$DOMAINS_FILE"

echo "Scan complete."

#!/bin/bash

SWAGGER_TEMPLATE="$HOME/nuclei-templates/http/exposures/apis/swagger-api.yaml"
DOMAINS_FILE="domains.txt"
OUTPUT_FILE="nuclei_swagger_scan"
URL_FILE="temp_swagger_endpoints.txt"
FINAL_URL_FILE="swagger_endpoints.txt"
USE_TOR=false
GOBIN=""

counter=1

# Function to parse command-line arguments
parse_arguments() {
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
}

# Function to check if the domains file exists
check_domains_file() {
    if [ ! -f "$DOMAINS_FILE" ]; then
        echo "Domains file not found: $DOMAINS_FILE"
        exit 1
    fi
}

# Function to set up Tor if required
setup_tor() {
    if [[ "$USE_TOR" == true ]]; then
        export https_proxy=socks5://127.0.0.1:9050
        export http_proxy=socks5://127.0.0.1:9050
        echo "Using Tor for Nuclei scans..."
    fi
}

# Function to determine the Nuclei command path
get_nuclei_command() {
    if [[ -n "$GOBIN" ]]; then
        NUCLEI_CMD="${GOBIN}/nuclei"
    else
        NUCLEI_CMD="nuclei"
    fi
}

# Function to split the domains file into chunks
split_domains_file() {
    split -l 501 "$DOMAINS_FILE" domains_chunk_
}

# Function to process each chunk
process_chunks() {
    for chunk in domains_chunk_*; do
        echo "Processing chunk: $chunk"
        
        output_chunk_file="${OUTPUT_FILE}_${counter}.txt"

        echo "Running Nuclei on chunk: $chunk"
        "$NUCLEI_CMD" -list "$chunk" -t "$SWAGGER_TEMPLATE" -o "$output_chunk_file"
        
        grep -oP '(?<=info] ).*(?= \[)' "$output_chunk_file" >> "$URL_FILE"
        
        ((counter++))
    done
}

# Function to perform post-processing after chunk processing
after_process() {
    sort -u "$URL_FILE" > "$FINAL_URL_FILE"
    rm $URL_FILE
    rm domains_chunk_*

    if [[ "$USE_TOR" == true ]]; then
        unset https_proxy http_proxy
    fi

    # add existing stuff to final file
    grep -H . "${OUTPUT_FILE}_*" > "${OUTPUT_FILE}.txt"

    # delete chunk output files
    rm "${OUTPUT_FILE}_*"

for file in "nuclei_swagger_scan_*"; do [ -s "$file" ] || rm "$file"; done


    echo "Scan complete. Unique URLs saved to $FINAL_URL_FILE."
}

# Main function to orchestrate the script
main() {
    parse_arguments "$@"
    check_domains_file
    : > "$URL_FILE"
    : > "$FINAL_URL_FILE"
    
    setup_tor
    get_nuclei_command
    split_domains_file
    process_chunks
    after_process
}

# Execute the main function
main "$@"

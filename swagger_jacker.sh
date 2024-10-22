#!/bin/bash

INPUT_FILE="swagger_endpoints.txt"
OUTPUT_FILE="$HOME/hack/resources/wordlists/swagger-jacker-api-wild.json"
CLEANED_FILE="swagger-jacker-api-wild.txt"
SJ_CMD=""
USE_TOR=false
GOBIN=""

# parse command-line arguments
parse_arguments() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --tor) 
                USE_TOR=true
                shift
                ;;
            --vps)
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

# set up Tor if required
setup_tor() {
    if [[ "$USE_TOR" == true ]]; then
        export https_proxy=socks5://127.0.0.1:9050
        export http_proxy=socks5://127.0.0.1:9050
        echo "Using Tor for swagger_jacker operations..."
    fi
}

# determine the swagger jacker command path
get_swagger_jacker_command() {
    if [[ -n "$GOBIN" ]]; then
        SJ_CMD="${GOBIN}/sj"
    else
        SJ_CMD="sj"
    fi
}

# check if the input file exists
check_input_file() {
    if [[ ! -f $INPUT_FILE ]]; then
        echo "File not found: $INPUT_FILE"
        exit 1
    fi
}

# initialize the output file
initialize_output_file() {
    if [[ ! -f $OUTPUT_FILE ]]; then
        echo "[] " > "$OUTPUT_FILE"
    fi
}

# clean up the endpoint file
clean_endpoint_file() {
    # remove everything after the first curly brace and trailing slashes, then remove duplicates
    sed 's/{.*//; s/\/$//' "$CLEANED_FILE" | sort -u > tmp_cleaned.txt && mv tmp_cleaned.txt "$CLEANED_FILE"
}

# process each URL
process_urls() {
    while IFS= read -r url; do
        echo "Running sj automate for: $url"
        "$SJ_CMD" automate -u "$url" --outfile swagger_jacker.json

        # post-process the JSON output and append it to the main file
        post_process swagger_jacker.json "$OUTPUT_FILE"
    done < "$INPUT_FILE"
}

# process and append results to the output file
post_process() {
    local json_file="$1"
    local output_file="$2"
    
    # append the 'results' array from the new JSON file to the output file
    jq '.results' "$json_file" | jq -s '.[0] + .' "$output_file" - > tmp.json && mv tmp.json "$output_file"
}

# clean up after processing
cleanup() {
    if [[ "$USE_TOR" == true ]]; then
        unset https_proxy http_proxy
    fi

    echo "New endpoints appended to $OUTPUT_FILE"
}

# main function to orchestrate the script
main() {
    parse_arguments "$@"
    setup_tor
    get_swagger_jacker_command
    check_input_file
    initialize_output_file
    clean_endpoint_file
    process_urls
    cleanup
}

main "$@"

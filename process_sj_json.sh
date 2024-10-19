#!/bin/bash

INPUT_FILE="swagger_jacker.json"
OUTPUT_FILE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -S|--status) STATUS_CODE="$2"; shift ;;
        -I|--input) INPUT_FILE="$2"; shift ;;
        -O|--output) OUTPUT_FILE="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [[ -z "$STATUS_CODE" ]]; then
    echo "Error: Status code is mandatory."
    echo "Usage: $0 --status <STATUS_CODE> [--input <INPUT_FILE>] [--output <OUTPUT_FILE>]"
    exit 1
fi

if [[ ! -f $INPUT_FILE ]]; then
    echo "Error: JSON file not found: $INPUT_FILE"
    exit 1
fi

if [[ -z "$OUTPUT_FILE" ]]; then
    OUTPUT_FILE="${INPUT_FILE%.json}_no_${STATUS_CODE}.json"
fi

BACKUP_FILE="${INPUT_FILE}.bak"
cp "$INPUT_FILE" "$BACKUP_FILE"
echo "Backup created: $BACKUP_FILE"

remove_junk() {
    local status="$1"
    local input="$2"
    local output="$3"
    jq --argjson code "$status" '.results |= map(select(.status != $code))' "$input" > "$output"
    echo "Removed entries with status code $status from $input and saved to $output"
}

remove_junk "$STATUS_CODE" "$INPUT_FILE" "$OUTPUT_FILE"

echo "Processing complete."

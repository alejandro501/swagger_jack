#!/bin/bash

WILDCARDS_FILE='wildcards.txt'

# Check if domains.txt exists
if [ ! -f domains.txt ]; then
    echo "The domains.txt file does not exist. Please create it first."
    exit 1
fi

echo "Starting subdomain enumeration..."

subfinder -dL "$WILDCARDS_FILE" | httprobe -c 50 --prefer-https | anew domains.txt

echo "Subdomain enumeration completed."
echo "Results added to domains.txt."

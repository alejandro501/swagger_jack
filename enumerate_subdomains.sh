#!/bin/bash

WILDCARDS_FILE='wildcards.txt'

if [ ! -f domains.txt ]; then
    echo "The domains.txt file does not exist. Please create it first."
    exit 1
fi

echo "Starting subdomain enumeration..."

if [[ "$1" == "--tor" ]]; then
    # Set proxy environment variables to use Tor (SOCKS5 proxy)
    export https_proxy=socks5://127.0.0.1:9050
    export http_proxy=socks5://127.0.0.1:9050
    echo "Using Tor for subdomain enumeration..."
fi

subfinder -dL "$WILDCARDS_FILE" | httprobe -c 50 --prefer-https | anew domains.txt

# Unset proxy variables after completion if used
if [[ "$1" == "--tor" ]]; then
    unset https_proxy http_proxy
fi

echo "Subdomain enumeration completed."
echo "Results added to domains.txt."

#!/bin/bash

BASE_PATH="."
if [[ "$1" == "--vps" ]]; then
    BASE_PATH="/root/hack/swagger_jacker"
    GOBIN="/root/go/bin"
else
    GOBIN=""
fi

WILDCARDS_FILE="$BASE_PATH/wildcards.txt"

if [ ! -f "$BASE_PATH/domains.txt" ]; then
    echo "The domains.txt file does not exist. Please create it first."
    exit 1
fi

echo "Starting subdomain enumeration..."

if [[ "$1" == "--tor" ]]; then
    export https_proxy=socks5://127.0.0.1:9050
    export http_proxy=socks5://127.0.0.1:9050
    echo "Using Tor for subdomain enumeration..."
fi

SUBFINDER_CMD="${GOBIN}subfinder"
HTTPROBE_CMD="${GOBIN}httprobe"

"$SUBFINDER_CMD" -dL "$WILDCARDS_FILE" | "$HTTPROBE_CMD" -c 50 --prefer-https | anew "$BASE_PATH/domains.txt"

if [[ "$1" == "--tor" ]]; then
    unset https_proxy http_proxy
fi

echo "Subdomain enumeration completed."
echo "Results added to domains.txt."

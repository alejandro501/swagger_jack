#!/bin/bash

BASE_PATH="."
if [[ "$1" == "--vps" ]]; then
    BASE_PATH="/root/hack/swagger_jacker"
    CURL_PATH="/usr/bin/curl"
else
    CURL_PATH="curl"
fi

source "$BASE_PATH/config.env"

send_discord_message() {
    MESSAGE=$1
    $CURL_PATH -H "Content-Type: application/json" \
               -X POST \
               -d "{\"content\": \"$MESSAGE\"}" \
               $DISCORD_WEBHOOK_URL
}

USE_TOR=false
VPS_ROOT=false

for arg in "$@"; do
    if [[ "$arg" == "--tor" ]]; then
        USE_TOR=true
    elif [[ "$arg" == "--vps" ]]; then
        VPS_ROOT=true
    fi
done

send_discord_message "Checking dependencies..."
$BASE_PATH/check_dependencies.sh

if [[ "$USE_TOR" == true ]]; then
    send_discord_message "Starting Tor service..."
    ./spinup_tor.sh
    send_discord_message "Enumerating subdomains with Tor..."
    $BASE_PATH/enumerate_subdomains.sh --tor
    send_discord_message "Finding Swagger with Tor..."
    $BASE_PATH/find_swagger.sh --tor
    send_discord_message "Running Swagger Jacker with Tor..."
    $BASE_PATH/swagger_jacker.sh --tor
elif [[ "$VPS_ROOT" == true ]]; then
    send_discord_message "Enumerating subdomains in VPS mode..."
    $BASE_PATH/enumerate_subdomains.sh --vps
    send_discord_message "Finding Swagger in VPS mode..."
    $BASE_PATH/find_swagger.sh --vps
    send_discord_message "Running Swagger Jacker in VPS mode..."
    $BASE_PATH/swagger_jacker.sh --vps
else
    send_discord_message "Enumerating subdomains..."
    $BASE_PATH/enumerate_subdomains.sh
    send_discord_message "Finding Swagger..."
    $BASE_PATH/find_swagger.sh
    send_discord_message "Running Swagger Jacker..."
    $BASE_PATH/swagger_jacker.sh
fi

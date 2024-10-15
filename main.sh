#!/bin/bash

# Source the environment variables from config.env
source config.env

send_discord_message() {
    MESSAGE=$1
    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"$MESSAGE\"}" \
         $DISCORD_WEBHOOK_URL
}

USE_TOR=false
if [[ "$1" == "--tor" ]]; then
    USE_TOR=true
    send_discord_message "Starting Tor service..."
    # Spin up Tor
    ./spinup_tor.sh
fi

send_discord_message "Checking dependencies..."
./check_dependencies.sh

if [[ "$USE_TOR" == true ]]; then
    send_discord_message "Enumerating subdomains with Tor..."
    ./enumerate_subdomains.sh --tor
    send_discord_message "Finding Swagger with Tor..."
    ./find_swagger.sh --tor
    send_discord_message "Running Swagger Jacker with Tor..."
    ./swagger_jacker.sh --tor
else
    send_discord_message "Enumerating subdomains..."
    ./enumerate_subdomains.sh
    send_discord_message "Finding Swagger..."
    ./find_swagger.sh
    send_discord_message "Running Swagger Jacker..."
    ./swagger_jacker.sh
fi

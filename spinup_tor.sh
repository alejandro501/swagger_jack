#!/bin/bash

check_tor() {
    if pgrep -x "tor" > /dev/null; then
        echo "Tor is already running."
    else
        echo "Tor is not running. Starting Tor..."
        tor &
        sleep 5 # wait for a few seconds to allow Tor to start
        if pgrep -x "tor" > /dev/null; then
            echo "Tor started successfully."
        else
            echo "Failed to start Tor. Please check your installation."
            exit 1
        fi
    fi
}

check_tor

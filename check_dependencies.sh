#!/bin/bash

check_dependencies() {
    # Check for required commands
    if ! command -v subfinder &>/dev/null; then
        echo "Subfinder is not installed. Please install it first."
        exit 1
    fi

    if ! command -v httprobe &>/dev/null; then
        echo "httprobe is not installed. Please install it first."
        exit 1
    fi

    if ! command -v anew &>/dev/null; then
        echo "anew is not installed. Please install it first."
        exit 1
    fi

    # Check for wildcards.txt file
    if [ ! -f wildcards.txt ]; then
        echo "The wildcards.txt file does not exist."
        exit 1
    fi
}

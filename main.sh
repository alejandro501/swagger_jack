#!/bin/bash

USE_TOR=false
if [[ "$1" == "--tor" ]]; then
    USE_TOR=true
    # Spin up Tor
    ./spinup_tor.sh
fi

./check_dependencies.sh

if [[ "$USE_TOR" == true ]]; then
    ./enumerate_subdomains.sh --tor
    ./find_swagger.sh --tor
    ./swagger_jacker.sh --tor
else
    ./enumerate_subdomains.sh
    ./find_swagger.sh
    ./swagger_jacker.sh
fi

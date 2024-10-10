#!/bin/bash

# after binary installation of my script we call it.
# bbp_domain_scraper --config config.json 

# add subdomains from wildcards
./check_dependencies.sh
./enumerate_subdomains.sh
./find_swagger.sh

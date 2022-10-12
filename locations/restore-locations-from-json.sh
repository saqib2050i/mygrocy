#!/bin/sh

#================================================
#  ?             Grocy Data Tools
#  @author      : uwbfritz
#  @email       : <uwbfritz@gmail.com>
#  @repo        : uwbfritz/grocy
#  @createdOn   : 2022-10-11
#  @description : Manage data in Grocy 
#================================================

# Load variables from .env file
ENV_FILE="../.env"
if [ ! -f $ENV_FILE ]
then
    echo "No .env file set, exiting"
else
    # shellcheck source=/dev/null
    . $ENV_FILE
fi

CATEGORY="locations"
APIURL=${APIURL}${CATEGORY}

# Check if new.txt exists and remove it
if [ -f new.txt ]; then
    rm -f new.txt
fi

jq -c '.[]' export/locations.json | while read -r i; do
    CMD=$(
        curl -s -X POST "$APIURL" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -H "GROCY-API-KEY: $APIKEY" \
        -d "$i"    
    )

    echo "$CMD" | grep -o '[[:digit:]]*' >> new.txt
done

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

CATEGORY="quantity_units"
APIURL=${APIURL}${CATEGORY}


CONTENT=$(curl -s -X 'GET' \
"$APIURL" \
-H "accept: application/json" \
-H "GROCY-API-KEY: $APIKEY")

echo "$CONTENT" | jq -c 'del(.[] | .id)' >  export/quantity_units.json



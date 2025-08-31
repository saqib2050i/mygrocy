#!/bin/sh

#================================================
#  ?             Grocy Data Tools
#  @author      : uwbfritz
#  @email       : <uwbfritz@gmail.com>
#  @repo        : uwbfritz/grocy
#  @createdOn   : 2022-10-11
#  @description : Manage data in Grocy (Product Groups)
#================================================

# Load variables from .env file
ENV_FILE="../.env"
if [ ! -f "$ENV_FILE" ]; then
    echo "No .env file set, exiting"
    exit 1
else
    # shellcheck source=/dev/null
    . "$ENV_FILE"
fi

CATEGORY="product_groups"
APIURL="${APIURL}${CATEGORY}"

# Iterate over source datafile (product_groups.txt)
while IFS= read -r line || [ -n "$line" ]; do
    id=$(echo "$line" | cut -d',' -f1)
    name=$(echo "$line" | cut -d',' -f2)
    description=$(echo "$line" | cut -d',' -f3)

    json_message=$(cat <<EOF
{
    "id": $id,
    "name": "$name",
    "description": "$description",
    "row_created_timestamp": "$(date +%Y-%m-%d\ %H:%M:%S)",
    "active": 1
}
EOF
)

    curl -s -X POST "$APIURL" \
      -H 'accept: application/json' \
      -H 'Content-Type: application/json' \
      -H "GROCY-API-KEY: $APIKEY" \
      -d "$json_message" || {
          echo "Failed to send JSON message for id: $id"
          exit 1
      }

    echo "Sent JSON message for id: $id ($name)"
done < product_groups.txt

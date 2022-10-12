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

CATEGORY="products"
APIURL=${APIURL}${CATEGORY}

# Get Date/Time in MM/DD/YYYY HH:MM:SS format
DATE=$(date +%m/%d/%Y\ %H:%M:%S)

# Iterate over source datafile
while read -r p; do
JSON_STRING=$(jq -n \
--arg location_id "7" \
--arg product_group_id "" \
--arg qu_factor_purchase_to_stock "1.0" \
--arg min_stock_amount "0" \
--arg qu_id_stock "51" \
--arg qu_id_purchase "51" \
--arg name "$p" \
--arg default_best_before_days "-1" \
--arg description "" \
--arg row_created_timestamp "$DATE" \
'$ARGS.named'
)

# Send JSON to API
curl -s -X POST "$APIURL" \
-H "accept: application/json" \
-H "Content-Type: application/json" \
-H "GROCY-API-KEY: $APIKEY" \
-d "$JSON_STRING"

done <./list/list.txt

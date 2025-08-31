#!/bin/sh
#================================================
#  ?             Grocy Data Tools (Refactored)
#  @author      : uwbfritz (refactored by ChatGPT)
#  @description : Manage data in Grocy (improved)
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

CATEGORY="products"
QU="quantity_units"
LOC="locations"
PG="product_groups"
API="${APIURL}${CATEGORY}"
APIQU="${APIURL}${QU}"
APILOC="${APIURL}${LOC}"
APIPG="${APIURL}${PG}"

# Functions to fetch IDs from Grocy API
get_quantity_unit_id() {
    curl -s -X 'GET' "$APIQU" -H "accept: application/json" -H "GROCY-API-KEY: $APIKEY" \
    | jq -r ".[] | select(.name == \"$1\") | .id"
}

get_locations_id() {
    curl -s -X 'GET' "$APILOC" -H "accept: application/json" -H "GROCY-API-KEY: $APIKEY" \
    | jq -r ".[] | select(.name == \"$1\") | .id"
}

get_product_group_id() {
    curl -s -X 'GET' "$APIPG" -H "accept: application/json" -H "GROCY-API-KEY: $APIKEY" \
    | jq -r ".[] | select(.name == \"$1\") | .id"
}

# Log file
LOGFILE="grocy_import.log"
touch "$LOGFILE"

# Create newlist.txt if it doesn't exist
touch newlist.txt

# Detect sed flavor (GNU or BSD/macOS)
if sed --version >/dev/null 2>&1; then
    SED="sed -i"
else
    SED="sed -i ''"
fi

# Process list.txt line by line
while IFS=',' read -r id name description product_group location qu_purchase qu_stock default_consume_location qu_consume qu_price; do
    # Skip comments or empty lines
    [ -z "$id" ] && continue
    [ "${id#\#}" != "$id" ] && continue

    product_group_id=$(get_product_group_id "$product_group")
    location_id=$(get_locations_id "$location")
    qu_id_purchase=$(get_quantity_unit_id "$qu_purchase")
    qu_id_stock=$(get_quantity_unit_id "$qu_stock")
    default_consume_location_id=$(get_locations_id "$default_consume_location")
    qu_id_consume=$(get_quantity_unit_id "$qu_consume")
    qu_id_price=$(get_quantity_unit_id "$qu_price")

    # JSON payload (without manual ID)
    json_message=$(cat <<EOF
{
    "name": "$name",
    "description": "$description",
    "product_group_id": ${product_group_id:-null},
    "active": 1,
    "location_id": ${location_id:-null},
    "shopping_location_id": null,
    "qu_id_purchase": ${qu_id_purchase:-null},
    "qu_id_stock": ${qu_id_stock:-null},
    "min_stock_amount": 0,
    "default_best_before_days": 0,
    "default_best_before_days_after_open": 0,
    "default_best_before_days_after_freezing": 0,
    "default_best_before_days_after_thawing": 0,
    "picture_file_name": null,
    "enable_tare_weight_handling": 0,
    "tare_weight": 0,
    "not_check_stock_fulfillment_for_recipes": 0,
    "parent_product_id": null,
    "calories": 0,
    "cumulate_min_stock_amount_of_sub_products": 0,
    "due_type": 1,
    "quick_consume_amount": 1,
    "hide_on_stock_overview": 0,
    "default_stock_label_type": 0,
    "should_not_be_frozen": 0,
    "treat_opened_as_out_of_stock": 1,
    "no_own_stock": 0,
    "default_consume_location_id": ${default_consume_location_id:-null},
    "move_on_open": 0,
    "row_created_timestamp": "$(date +"%Y-%m-%d %H:%M:%S")",
    "qu_id_consume": ${qu_id_consume:-null},
    "auto_reprint_stock_label": 0,
    "quick_open_amount": 1,
    "qu_id_price": ${qu_id_price:-null}
}
EOF
)

    # Send request
    response=$(curl -s -w "|HTTPSTATUS:%{http_code}" -X POST "$API" \
      -H 'accept: application/json' \
      -H 'Content-Type: application/json' \
      -H "GROCY-API-KEY: $APIKEY" \
      -d "$json_message")

    # Split response and HTTP status
    body=$(echo "$response" | sed -e 's/|HTTPSTATUS:.*//g')
    status=$(echo "$response" | tr -d '\n' | sed -e 's/.*|HTTPSTATUS://')

    if [ "$status" -eq 200 ] && echo "$body" | jq -e '.created_object_id' >/dev/null 2>&1; then
        echo "[$(date)] SUCCESS: Imported $name ($id)" | tee -a "$LOGFILE"
        echo "$body" | tee -a "$LOGFILE"

        # Move line to newlist.txt
        $SED "/^$id,/d" list.txt
        echo "$id,$name,$description,$product_group,$location,$qu_purchase,$qu_stock,$default_consume_location,$qu_consume,$qu_price" >> newlist.txt
    else
        echo "[$(date)] ERROR: Failed to import $name ($id)" | tee -a "$LOGFILE"
        echo "Response: $body | HTTP $status" | tee -a "$LOGFILE"
    fi

done < list.txt

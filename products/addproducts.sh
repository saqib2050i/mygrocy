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
if [ ! -f "$ENV_FILE" ]; then
    echo "No .env file set, exiting"
    exit 1
else
    # shellcheck source=/dev/null
    . "$ENV_FILE"
fi

CATEGORY="quantity_units"
APIURL="${APIURL}${CATEGORY}"

# Get Date/Time in MM/DD/YYYY HH:MM:SS format
DATE=$(date +%m/%d/%Y\ %H:%M:%S)

# Iterate over source datafile
sed 1d list.txt | while IFS= read -r line; do
    id=$(echo "$line" | cut -d ' ' -f 1)
    name=$(echo "$line" | cut -d ' ' -f 2)
    description=$(echo "$line" | cut -d ' ' -f 3)
    product_group_id=$(echo "$line" | cut -d ' ' -f 4)
    location_id=$(echo "$line" | cut -d ' ' -f 5)
    qu_id_purchase=$(echo "$line" | cut -d ' ' -f 6)
    qu_id_stock=$(echo "$line" | cut -d ' ' -f 7)
    default_consume_location_id=$(echo "$line" | cut -d ' ' -f 8)
    qu_id_consume=$(echo "$line" | cut -d ' ' -f 9)
    qu_id_price=$(echo "$line" | cut -d ' ' -f 10)

    # Generate JSON
    cat <<EOF >"${name}.json"
{
    "id": ${id},
    "name": "${name}",
    "description": "${description}",
    "product_group_id": ${product_group_id},
    "active": 1,
    "location_id": ${location_id},
    "shopping_location_id": null,
    "qu_id_purchase": ${qu_id_purchase},
    "qu_id_stock": ${qu_id_stock},
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
    "default_consume_location_id": ${default_consume_location_id},
    "move_on_open": 0,
    "row_created_timestamp": "$(date +"%Y-%m-%d %H:%M:%S")",
    "qu_id_consume": ${qu_id_consume},
    "auto_reprint_stock_label": 0,
    "quick_open_amount": 1,
    "qu_id_price": ${qu_id_price}
}
EOF

    curl -s -X POST "$APIURL" \
      -H 'accept: application/json' \
      -H 'Content-Type: application/json' \
      -H "GROCY-API-KEY: $APIKEY" \
      -d "$json_message" || {
          echo "Failed to send JSON message for id: $id"
          exit 1
      }

    echo "Sent JSON message for id: $id"
done < list.txt

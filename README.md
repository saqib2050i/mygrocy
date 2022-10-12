![Build Status](https://github.com/uwbfritz/grocy-api-tools/actions/workflows/shellcheck.yml/badge.svg)
# Grocy API Tools

Various scripts that you can use to manipulate the Grocy API. 

**Warning:** Exporting and reimporting data into an instance will cause orphaned relationships between your products and their location, etc... These tools are best used for a fresh instance, or for importing raw product lists. 

## Prerequisites

**jq** must be installed. 
```
# Debian variants
apt install jq -y

# Redhat variants
dnf install jq -y

# Alpine
apk add jq
```
## Installation / Configuration

- Clone this repo
- Modify the .env file to match your environment
```
APIURL="https://xxxxx/api/objects/"
APIKEY="xxxx"
```

## Features

**Products**:
- Import new products from a txt list (see /products/list/list.txt)
- Export to JSON file
- Import from JSON file
- Delete all entries

**Locations**: 
- Export to JSON file
- Import from JSON file
- Delete all entries

**Product Groups**:
- Export to JSON file
- Import from JSON file
- Delete all entries

**Quantity Units**:
- Export to JSON file
- Import from JSON file
- Delete all entries

**Stores**:
- Export to JSON file
- Import from JSON file
- Delete all entries

```
├── .env                                                  # EDIT before use
├── README.md                                             # This file
├── locations 
│   ├── delete-locations.sh                               
│   ├── export                                            # JSON export/import location
│   ├── export-locations.sh
│   └── restore-locations-from-json.sh
├── product-groups
│   ├── delete-product-groups.sh
│   ├── export                                            # JSON export/import location
│   ├── export-product-groups.sh
│   └── restore-product-groups-from-json.sh
├── products
│   ├── add-products-from-list.sh
│   ├── delete-products.sh
│   ├── export                                            # JSON export/import location
│   ├── export-products.sh
│   ├── list
│   │   └── list.txt                                      # Import list (one per line. You will want to edit the IDs in the add-products script before running)
│   └── restore-products-from-json.sh
├── quantity-units
│   ├── delete-quantity-units.sh
│   ├── export                                            # JSON export/import location
│   ├── export-quantity-units.sh
│   └── restore-quantity-units-from-json.sh
└── stores
    ├── delete-stores.sh
    ├── export                                            # JSON export/import location
    ├── export-stores.sh
    └── restore-stores-from-json.sh
```

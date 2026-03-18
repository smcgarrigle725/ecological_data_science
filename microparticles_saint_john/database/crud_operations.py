"""
crud_operations.py
------------------
Create, Read, Update, and Delete operations for all 5 DynamoDB tables:
    Site, Animal, Sediment, Water, FTIR

Primary keys:
    Site     → siteid
    Animal   → id
    Sediment → id
    Water    → id
    FTIR     → mp_id

Usage:
    Import individual functions into analysis scripts or notebooks, or
    run this file directly to see a worked example.

    from crud_operations import read_item, update_item

Requirements:
    pip install boto3
    IAM permissions: dynamodb:PutItem, dynamodb:GetItem,
                     dynamodb:UpdateItem, dynamodb:DeleteItem
"""

import boto3
from botocore.exceptions import ClientError

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

REGION = "us-east-1"
dynamodb = boto3.resource("dynamodb", region_name=REGION)

VALID_TABLES = {"Site", "Animal", "Sediment", "Water", "FTIR"}

PRIMARY_KEYS = {
    "Site":     "siteid",
    "Animal":   "id",
    "Sediment": "id",
    "Water":    "id",
    "FTIR":     "mp_id",
}

# ---------------------------------------------------------------------------
# Generic CRUD
# ---------------------------------------------------------------------------

def create_item(table_name, item):
    """
    Insert or fully overwrite a single item.

    Args:
        table_name (str): One of Site, Animal, Sediment, Water, FTIR.
        item (dict):      Item attributes. Must include the table's primary key.

    Returns:
        bool: True on success, False on failure.

    Example:
        create_item("Site", {
            "siteid": "2022_HarbourNorth_Water",
            "waterbody": "Saint John Harbour",
            "collection_organization": "ACAP Saint John",
            ...
        })
    """
    if table_name not in VALID_TABLES:
        raise ValueError(f"table_name must be one of {VALID_TABLES}")
    try:
        dynamodb.Table(table_name).put_item(Item=item)
        pk = PRIMARY_KEYS[table_name]
        print(f"[create] Written to {table_name}: {pk}='{item.get(pk)}'")
        return True
    except ClientError as e:
        print(f"[error]  create_item failed on {table_name}: {e}")
        return False


def read_item(table_name, key_value):
    """
    Retrieve a single item by its primary key value.

    Args:
        table_name (str): One of Site, Animal, Sediment, Water, FTIR.
        key_value (str):  The primary key value (siteid, id, or mp_id).

    Returns:
        dict | None: The item if found, None otherwise.

    Example:
        item = read_item("Site", "2019SSX US2Water")
        item = read_item("FTIR", "2022_HarbourNorth_Animal_S01_03")
    """
    if table_name not in VALID_TABLES:
        raise ValueError(f"table_name must be one of {VALID_TABLES}")
    pk = PRIMARY_KEYS[table_name]
    try:
        response = dynamodb.Table(table_name).get_item(Key={pk: key_value})
        item = response.get("Item")
        if item:
            print(f"[read]   Found: {table_name} {pk}='{key_value}'")
        else:
            print(f"[read]   Not found: {table_name} {pk}='{key_value}'")
        return item
    except ClientError as e:
        print(f"[error]  read_item failed on {table_name}: {e}")
        return None


def update_item(table_name, key_value, updates):
    """
    Update specific attributes on an existing item.
    Only the attributes listed in `updates` are changed; others are untouched.

    Args:
        table_name (str):  One of Site, Animal, Sediment, Water, FTIR.
        key_value (str):   The primary key value.
        updates (dict):    Attributes to update: {attribute_name: new_value}.

    Returns:
        bool: True on success, False on failure.

    Example:
        update_item("Site", "2019SSX US2Water", {"substrate": "Sand/gravel"})
        update_item("FTIR", "2022_HarbourNorth_Animal_S01_03", {"common_plastic": "Y"})
    """
    if table_name not in VALID_TABLES:
        raise ValueError(f"table_name must be one of {VALID_TABLES}")
    pk = PRIMARY_KEYS[table_name]

    update_expr  = "SET " + ", ".join(f"#{k} = :{k}" for k in updates)
    expr_names   = {f"#{k}": k for k in updates}
    expr_values  = {f":{k}": v for k, v in updates.items()}

    try:
        dynamodb.Table(table_name).update_item(
            Key={pk: key_value},
            UpdateExpression=update_expr,
            ExpressionAttributeNames=expr_names,
            ExpressionAttributeValues=expr_values,
        )
        print(f"[update] {table_name} {pk}='{key_value}': updated {list(updates.keys())}")
        return True
    except ClientError as e:
        print(f"[error]  update_item failed on {table_name}: {e}")
        return False


def delete_item(table_name, key_value):
    """
    Delete a single item by its primary key value.

    Args:
        table_name (str): One of Site, Animal, Sediment, Water, FTIR.
        key_value (str):  The primary key value.

    Returns:
        bool: True on success, False on failure.

    Example:
        delete_item("Animal", "2022_HarbourNorth_Animal_S01")
    """
    if table_name not in VALID_TABLES:
        raise ValueError(f"table_name must be one of {VALID_TABLES}")
    pk = PRIMARY_KEYS[table_name]
    try:
        dynamodb.Table(table_name).delete_item(Key={pk: key_value})
        print(f"[delete] Removed from {table_name}: {pk}='{key_value}'")
        return True
    except ClientError as e:
        print(f"[error]  delete_item failed on {table_name}: {e}")
        return False


# ---------------------------------------------------------------------------
# Example usage
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    # Read an existing site — replace with a real siteid from your database
    print("=== Read ===")
    site = read_item("Site", "2019SSX US2Water")
    if site:
        print(site)

    # Example update
    print("\n=== Update ===")
    update_item("Site", "2019SSX US2Water", {"substrate": "Cobble/gravel — verified"})

    # Confirm update
    print("\n=== Read after update ===")
    read_item("Site", "2019SSX US2Water")

    # Example create (uncomment to run)
    # print("\n=== Create ===")
    # create_item("Site", {
    #     "siteid": "2024_TestSite_Water",
    #     "waterbody": "Test Waterbody",
    #     "collection_organization": "University of New Brunswick",
    #     "primarycontact": "Heather Hunt",
    #     "year": "2024",
    #     "waterbodytype": "Freshwater",
    #     "site": "Test Site",
    #     "latitude": "45.2700",
    #     "longitude": "-66.0633",
    # })

    # Example delete (uncomment to run — permanent)
    # print("\n=== Delete ===")
    # delete_item("Site", "2024_TestSite_Water")

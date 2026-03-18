"""
view_dynamodb.py
----------------
Inspect DynamoDB tables for the microparticles_saint_john project.

With no arguments, prints a summary of all 5 tables (status and item count).
With --table, also prints a sample of records from that table as a DataFrame.

Usage:
    # Summarise all tables
    python view_dynamodb.py

    # Inspect a specific table
    python view_dynamodb.py --table Water
    python view_dynamodb.py --table FTIR --limit 20
    python view_dynamodb.py --table Site --region us-east-1

Arguments:
    --table     Table to inspect: Site, Animal, Sediment, Water, FTIR
    --limit     Number of sample records to display (default: 5)
    --region    AWS region (default: us-east-1)

Requirements:
    pip install boto3 pandas
    IAM permissions: dynamodb:ListTables, dynamodb:DescribeTable, dynamodb:Scan
"""

import argparse
from decimal import Decimal

import boto3
import pandas as pd
from botocore.exceptions import ClientError

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

REGION = "us-east-1"
ALL_TABLES = ["Site", "Animal", "Sediment", "Water", "FTIR"]

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def get_client(region):
    return boto3.client("dynamodb", region_name=region)

def get_resource(region):
    return boto3.resource("dynamodb", region_name=region)

def decimals_to_float(df):
    """Convert Decimal columns to float for clean display."""
    return df.applymap(lambda x: float(x) if isinstance(x, Decimal) else x)


def describe_table(client, table_name):
    """Print a one-line summary of a table's status and item count."""
    try:
        t = client.describe_table(TableName=table_name)["Table"]
        status     = t["TableStatus"]
        item_count = t.get("ItemCount", "N/A")
        size_bytes = t.get("TableSizeBytes", "N/A")
        print(f"  {table_name:<12} status: {status:<8}  "
              f"items (approx): {item_count:<8}  size: {size_bytes} bytes")
    except ClientError as e:
        if e.response["Error"]["Code"] == "ResourceNotFoundException":
            print(f"  {table_name:<12} [NOT FOUND]")
        else:
            raise


def scan_sample(resource, table_name, limit):
    """Scan and return up to `limit` items from a table as a DataFrame."""
    table = resource.Table(table_name)
    try:
        response = table.scan(Limit=limit)
        items = response.get("Items", [])
        if not items:
            print(f"\n  No items found in '{table_name}'.")
            return
        df = pd.DataFrame(items)
        df = decimals_to_float(df)
        print(f"\n  Sample records from '{table_name}' ({len(items)} shown):\n")
        print(df.to_string(index=False))
    except ClientError as e:
        print(f"\n  [error] Could not scan {table_name}: {e}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="View DynamoDB table contents.")
    parser.add_argument("--table",  default=None,
                        help="Table to inspect. Omit to summarise all tables.")
    parser.add_argument("--limit",  type=int, default=5,
                        help="Number of sample records to display (default: 5).")
    parser.add_argument("--region", default=REGION, help="AWS region.")
    args = parser.parse_args()

    client   = get_client(args.region)
    resource = get_resource(args.region)

    print(f"\nRegion: {args.region}\n")
    print("Table summary:")
    print("-" * 65)

    tables_to_check = [args.table] if args.table else ALL_TABLES
    for t in tables_to_check:
        describe_table(client, t)

    if args.table:
        print()
        scan_sample(resource, args.table, args.limit)

    print()

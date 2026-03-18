"""
table_setup.py
--------------
Creates all 5 DynamoDB tables for the microparticles_saint_john project:
    Site, Animal, Sediment, Water, FTIR

Tables were originally created manually via the AWS console. This script
reproduces that setup programmatically for documentation and reproducibility.

Run this script once to provision tables in a new AWS environment.
Tables use PAY_PER_REQUEST billing — no capacity planning required.

Usage:
    python table_setup.py

Requirements:
    pip install boto3
    AWS credentials configured via `aws configure` or environment variables.
    IAM permissions: dynamodb:CreateTable, dynamodb:DescribeTable
"""

import boto3
import time
from botocore.exceptions import ClientError

# ---------------------------------------------------------------------------
# Configuration — update region if deploying outside us-east-1
# ---------------------------------------------------------------------------

REGION = "us-east-1"

dynamodb = boto3.client("dynamodb", region_name=REGION)

# ---------------------------------------------------------------------------
# Table definitions
# ---------------------------------------------------------------------------

TABLES = [
    {
        "TableName": "Site",
        "KeySchema": [
            {"AttributeName": "siteid", "KeyType": "HASH"}
        ],
        "AttributeDefinitions": [
            {"AttributeName": "siteid",    "AttributeType": "S"},
            {"AttributeName": "waterbody", "AttributeType": "S"},
        ],
        "GlobalSecondaryIndexes": [
            {
                "IndexName": "waterbody-index",
                "KeySchema": [
                    {"AttributeName": "waterbody", "KeyType": "HASH"}
                ],
                "Projection": {"ProjectionType": "ALL"},
            }
        ],
        "BillingMode": "PAY_PER_REQUEST",
    },
    {
        "TableName": "Animal",
        "KeySchema": [
            {"AttributeName": "id", "KeyType": "HASH"}
        ],
        "AttributeDefinitions": [
            {"AttributeName": "id",     "AttributeType": "S"},
            {"AttributeName": "siteid", "AttributeType": "S"},
        ],
        "GlobalSecondaryIndexes": [
            {
                "IndexName": "siteid-index",
                "KeySchema": [
                    {"AttributeName": "siteid", "KeyType": "HASH"}
                ],
                "Projection": {"ProjectionType": "ALL"},
            }
        ],
        "BillingMode": "PAY_PER_REQUEST",
    },
    {
        "TableName": "Sediment",
        "KeySchema": [
            {"AttributeName": "id", "KeyType": "HASH"}
        ],
        "AttributeDefinitions": [
            {"AttributeName": "id",     "AttributeType": "S"},
            {"AttributeName": "siteid", "AttributeType": "S"},
        ],
        "GlobalSecondaryIndexes": [
            {
                "IndexName": "siteid-index",
                "KeySchema": [
                    {"AttributeName": "siteid", "KeyType": "HASH"}
                ],
                "Projection": {"ProjectionType": "ALL"},
            }
        ],
        "BillingMode": "PAY_PER_REQUEST",
    },
    {
        "TableName": "Water",
        "KeySchema": [
            {"AttributeName": "id", "KeyType": "HASH"}
        ],
        "AttributeDefinitions": [
            {"AttributeName": "id",     "AttributeType": "S"},
            {"AttributeName": "siteid", "AttributeType": "S"},
        ],
        "GlobalSecondaryIndexes": [
            {
                "IndexName": "siteid-index",
                "KeySchema": [
                    {"AttributeName": "siteid", "KeyType": "HASH"}
                ],
                "Projection": {"ProjectionType": "ALL"},
            }
        ],
        "BillingMode": "PAY_PER_REQUEST",
    },
    {
        "TableName": "FTIR",
        "KeySchema": [
            {"AttributeName": "mp_id", "KeyType": "HASH"}
        ],
        "AttributeDefinitions": [
            {"AttributeName": "mp_id", "AttributeType": "S"},
            {"AttributeName": "id",    "AttributeType": "S"},
        ],
        "GlobalSecondaryIndexes": [
            {
                "IndexName": "id-index",
                "KeySchema": [
                    {"AttributeName": "id", "KeyType": "HASH"}
                ],
                "Projection": {"ProjectionType": "ALL"},
            }
        ],
        "BillingMode": "PAY_PER_REQUEST",
    },
]

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def table_exists(table_name):
    try:
        dynamodb.describe_table(TableName=table_name)
        return True
    except ClientError as e:
        if e.response["Error"]["Code"] == "ResourceNotFoundException":
            return False
        raise


def create_table(table_def):
    name = table_def["TableName"]
    if table_exists(name):
        print(f"  [skip]   {name} already exists.")
        return

    try:
        dynamodb.create_table(**table_def)
        print(f"  [create] {name} — waiting for ACTIVE status...")
        waiter = dynamodb.get_waiter("table_exists")
        waiter.wait(TableName=name)
        print(f"  [ready]  {name} is ACTIVE.")
    except ClientError as e:
        print(f"  [error]  {name}: {e}")
        raise


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    print(f"Creating tables in region: {REGION}\n")
    for table_def in TABLES:
        create_table(table_def)
        time.sleep(0.5)
    print("\nDone.")

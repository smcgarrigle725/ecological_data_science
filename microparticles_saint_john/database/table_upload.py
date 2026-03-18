"""
table_upload.py
---------------
Uploads rows from a CSV file into a DynamoDB table.
Uploads in batches of 500 rows using DynamoDB's batch_writer,
which internally handles the 25-item API limit automatically.

Empty string values are dropped rather than stored — DynamoDB does
not accept empty strings as attribute values.

Usage:
    python table_upload.py --table FTIR --csv path/to/FTIR.csv
    python table_upload.py --table Site --csv path/to/Site.csv --region us-east-1

Arguments:
    --table     DynamoDB table name (Site, Animal, Sediment, Water, FTIR)
    --csv       Path to the input CSV file
    --region    AWS region (default: us-east-1)

Requirements:
    pip install boto3
    AWS credentials configured via `aws configure` or environment variables.
    IAM permissions: dynamodb:BatchWriteItem
"""

import argparse
import csv
import math
import time
import boto3
from botocore.exceptions import ClientError

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

BATCH_SIZE = 500     # Rows per progress-reporting chunk.
                     # boto3 batch_writer handles the DynamoDB 25-item limit internally.
VALID_TABLES = {"Site", "Animal", "Sediment", "Water", "FTIR"}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def clean_item(row):
    """
    Convert a CSV row dict into a DynamoDB item.
    Drops empty string values — DynamoDB rejects them as attribute values.
    """
    return {k: v for k, v in row.items() if v != ""}


def upload_batch(table, items):
    """Write a list of item dicts using batch_writer. Returns count written."""
    written = 0
    with table.batch_writer() as batch:
        for item in items:
            batch.put_item(Item=item)
            written += 1
    return written


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def upload_csv(table_name, csv_path, region):
    if table_name not in VALID_TABLES:
        raise ValueError(f"Table must be one of: {VALID_TABLES}")

    print(f"\nUploading '{csv_path}' → {table_name} ({region})")

    # Read CSV
    with open(csv_path, "r", encoding="utf-8-sig") as f:  # utf-8-sig handles Excel BOM
        reader = csv.DictReader(f)
        rows = [clean_item(row) for row in reader]

    total = len(rows)
    print(f"  Rows to upload: {total}")

    if total == 0:
        print("  No rows found. Check that the CSV has a header row and data.")
        return

    # Connect to table
    dynamodb = boto3.resource("dynamodb", region_name=region)
    table = dynamodb.Table(table_name)

    # Upload in chunks of BATCH_SIZE
    num_batches = math.ceil(total / BATCH_SIZE)
    total_written = 0

    for i in range(num_batches):
        chunk = rows[i * BATCH_SIZE : (i + 1) * BATCH_SIZE]
        print(f"  Batch {i + 1}/{num_batches} ({len(chunk)} rows)...", end=" ", flush=True)

        retries = 0
        while retries < 3:
            try:
                written = upload_batch(table, chunk)
                total_written += written
                print(f"OK  ({total_written}/{total} total)")
                break
            except ClientError as e:
                code = e.response["Error"]["Code"]
                if code == "ProvisionedThroughputExceededException":
                    retries += 1
                    wait = 2 ** retries
                    print(f"throughput exceeded — retrying in {wait}s...")
                    time.sleep(wait)
                else:
                    print(f"\n  [error] {e}")
                    raise

    print(f"\nUpload complete: {total_written}/{total} rows written to '{table_name}'.")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Upload a CSV to a DynamoDB table in 500-row batches."
    )
    parser.add_argument("--table",  required=True, help="DynamoDB table name")
    parser.add_argument("--csv",    required=True, help="Path to CSV file")
    parser.add_argument("--region", default="us-east-1", help="AWS region")
    args = parser.parse_args()

    upload_csv(args.table, args.csv, args.region)

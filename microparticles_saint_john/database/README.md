# Database

This directory contains all Python scripts for setting up, populating, and querying the AWS DynamoDB database for the microparticles_saint_john project.

---

## Files

| Script | Description |
|--------|-------------|
| `table_setup.py` | Create all 5 DynamoDB tables programmatically |
| `table_upload.py` | Batch-upload rows from a CSV (500 rows/batch) into any table |
| `view_dynamodb.py` | Inspect table status, item counts, and sample records |
| `crud_operations.py` | Create, Read, Update, Delete operations for all 5 tables |
| `data_extraction.py` | Query and extract data into pandas DataFrames |
| `joining_tables.py` | Assemble joined datasets (Site + sample matrix ± FTIR) |

---

## Setup

### 1. Install dependencies

```bash
pip install boto3 pandas
```

### 2. Configure AWS credentials

Credentials are never stored in this repository. Configure one of the following ways:

```bash
# Option A: AWS CLI (recommended)
aws configure

# Option B: environment variables
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_DEFAULT_REGION=us-east-1
```

Required IAM permissions:
- `dynamodb:CreateTable`, `dynamodb:DescribeTable`, `dynamodb:ListTables`
- `dynamodb:BatchWriteItem`, `dynamodb:PutItem`
- `dynamodb:GetItem`, `dynamodb:UpdateItem`, `dynamodb:DeleteItem`
- `dynamodb:Scan`, `dynamodb:Query`

---

## Recommended Workflow

```bash
# Step 1: Create all 5 tables
python table_setup.py

# Step 2: Upload data from CSVs
python table_upload.py --table Site     --csv path/to/Site.csv
python table_upload.py --table Animal   --csv path/to/Animal.csv
python table_upload.py --table Sediment --csv path/to/Sediment.csv
python table_upload.py --table Water    --csv path/to/Water.csv
python table_upload.py --table FTIR     --csv path/to/FTIR.csv

# Step 3: Verify upload
python view_dynamodb.py
python view_dynamodb.py --table Water --limit 10

# Step 4: Query and extract data for analysis
python data_extraction.py

# Step 5: Build joined datasets
python joining_tables.py
```

---

## CSV Format Requirements

CSV column names must exactly match the DynamoDB attribute names defined in `../schema/dynamodb_schema.json`. See `../schema/README.md` for the full attribute list per table.

- Primary key columns (`siteid`, `id`, `mp_id`) must be populated for every row.
- Empty cells are automatically dropped during upload — DynamoDB does not accept empty string values.
- CSV files exported from Excel should be saved as **CSV UTF-8** to avoid encoding issues with the byte-order mark (BOM).
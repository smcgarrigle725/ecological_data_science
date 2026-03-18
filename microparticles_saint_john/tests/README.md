# Tests

This directory is a placeholder for unit and integration tests. No tests are implemented yet — this documents the planned test suite for future development.

---

## Planned Tests

| Test file | Target script | Description |
|-----------|--------------|-------------|
| `test_table_setup.py` | `database/table_setup.py` | Verify all 5 tables are created with correct key schema and GSIs |
| `test_upload.py` | `database/table_upload.py` | Test batch upload with a small synthetic CSV; verify row counts match |
| `test_crud.py` | `database/crud_operations.py` | Test put/get/update/delete round-trips for each table |
| `test_extraction.py` | `database/data_extraction.py` | Verify scan and GSI queries return non-empty DataFrames with expected columns |
| `test_joins.py` | `database/joining_tables.py` | Verify joined outputs contain expected columns, correct row counts, and no cross-matrix contamination |

---

## Running Tests

```bash
pip install pytest moto
pytest tests/
```

`moto` is a library that mocks AWS services locally so tests can run without a live DynamoDB connection or AWS credentials. This makes tests safe to run in CI/CD pipelines.
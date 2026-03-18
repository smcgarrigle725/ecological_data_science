# Microparticles Saint John: Database, Analysis, and Dashboard

---

This repository contains the complete data pipeline, AWS DynamoDB database infrastructure, analysis scripts, and dashboard code supporting the collaborative microparticles research project in the Wolastoq/Saint John River watershed. The project integrates microparticle data from multiple partner organizations across animal, sediment, and water sample matrices, with a subset confirmed via micro-FTIR spectroscopy.

---

## Associated Publication

### Government Report
**Title:** Integration and data sharing to examine the fate and transport of microplastics in the Wolastoq/Saint John River watershed
**Authors:** Samantha McGarrigle<sup>1</sup>, Krista L. Beardy<sup>2</sup>, Claire Goodwin<sup>3</sup>, Joshua Kurek<sup>4</sup>, Kelly Mackarous<sup>5</sup>, Roxanne MacKinnon<sup>6</sup>, Alexa Meyer<sup>7</sup>, Brontë Thomas<sup>8</sup>, Tony R. Walker<sup>9</sup>, Heather L. Hunt<sup>10</sup>
**Report page:** To be added
**DOI:** To be added

**Affiliations:**
<sup>1</sup> University of New Brunswick, Saint John, NB
<sup>2</sup> University of New Brunswick, Saint John, NB
<sup>3</sup> Huntsman Marine Science Centre, St. Andrews, NB
<sup>4</sup> Mount Allison University, Sackville, NB
<sup>5</sup> Coastal Action, Mahone Bay, NS
<sup>6</sup> ACAP Saint John, Saint John, NB
<sup>7</sup> Passamaquoddy Recognition Group, St. Stephen, NB
<sup>8</sup> Passamaquoddy Recognition Group, St. Stephen, NB
<sup>9</sup> Dalhousie University, Halifax, NS
<sup>10</sup> University of New Brunswick, Saint John, NB

**Abstract:**

> Microplastics have been receiving more attention from researchers in recent years, including in Atlantic Canada, presenting a need to integrate, analyze, and publicly share this important data. In this project we developed a collaborative network of research expertise and diverse partners throughout the Maritimes to address knowledge gaps around plastic pollution and its impact on freshwater and coastal ecosystems. We brought together data on microparticles that were visually identified as potential microplastics in animal, sediment and water samples collected by multiple partner organizations throughout the Wolastoq/Saint John River watershed. Microparticles from a subset of the archived water and bivalve samples were sent for spectroscopic analysis (micro-FTIR) to confirm whether they were plastics and identify polymer composition. We compared patterns of microparticle concentration among rivers and Saint John Harbour. For bivalve, sediment, and water samples, we found differences in concentrations of visually identified microparticles among waterbodies. Saint John Harbour sites had higher concentrations of visually identified microparticles in bivalve and water samples than freshwater sites and the lowest concentrations in sediment samples. This analysis indicated that microparticles visually identified from water samples were more likely to be accurately identified as plastics (69%) than those in bivalve (16%) samples. PET was the most commonly occurring plastic compound identified in both water and bivalve samples. Our collaborative project demonstrates the value of collaboration and data sharing across partner organizations to examine patterns in microparticles and microplastics at the watershed scale.

---

### Peer-Reviewed Article
**Title:** To be added
**Journal:** To be added
**Article page:** To be added
**DOI:** To be added

---

## Repository Contents

```
.
├── README.md
├── .gitignore
│
├── schema/
│   ├── README.md                        # Schema documentation and design rationale
│   ├── dynamodb_schema.json             # Full table definitions (keys, attributes, indexes)
│   └── schema_diagram.md               # Entity-relationship description (Site → Water/Sediment/Animal → FTIR)
│
├── database/
│   ├── README.md                        # Database setup and usage instructions
│   ├── table_setup.py                   # Create all 5 DynamoDB tables
│   ├── table_upload.py                  # Batch upload from CSV (500 rows at a time)
│   ├── view_dynamodb.py                 # View table contents via console/boto3
│   ├── crud_operations.py               # Create, Read, Update, Delete operations
│   ├── data_extraction.py               # Extraction queries via boto3
│   └── joining_tables.py                # Join Site+Animal, Site+Water, Site+Sediment, and full Site+*+FTIR
│
├── dashboard/
│   ├── README.md                        # Dashboard options, cost analysis, schema considerations, stakeholder notes
│   ├── react/
│   │   ├── README.md                    # React app setup and deployment instructions
│   │   └── App.jsx                      # React (JavaScript) dashboard framework
│   └── streamlit/
│       ├── README.md                    # Streamlit app setup and deployment instructions
│       └── app.py                       # Streamlit (Python) dashboard framework
│
├── analysis/
│   ├── R/
│   │   ├── README.md                    # R analysis pipeline description
│   │   └── microparticles_analysis.R    # Main R analysis script
│   └── python/
│       ├── README.md                    # Python analysis pipeline description
│       └── microparticles_analysis.py   # Python conversion of R analysis
│
├── figures/
│   ├── README.md                        # Figure descriptions and generation notes
│   └── report_figures.R                 # Script to reproduce all report figures
│
├── data/
│   └── README.md                        # Dataset descriptions, column definitions, access instructions
│
├── outputs/
│   └── README.md                        # Output file descriptions
│
└── tests/
    └── README.md                        # Testing notes and placeholder for future unit tests
```

---

## Why DynamoDB? (Not PostgreSQL or SQL)

A relational database like PostgreSQL was considered for this project but ruled out for several reasons specific to this dataset and its collaborative context.

**Schema flexibility across partner organizations.** Data were collected by seven partner organizations using different protocols, species, and sampling designs. The animal, sediment, and water tables each have matrix-specific fields (e.g., `animallength`, `tissuetype` for animal samples; `samplevolume` for water; `sampleweight_wwt` for sediment) that do not apply across matrices. In a relational model this would require either a wide sparse table with many NULLs, or complex inheritance structures. DynamoDB's schemaless items handle this naturally — each item carries only the attributes relevant to its record.

**No server to manage.** PostgreSQL requires a hosted server (e.g., AWS RDS), ongoing maintenance, backups, and connection management. DynamoDB is fully serverless and managed by AWS, with no infrastructure overhead. For a research project with a small team and no dedicated database administrator, this is a significant practical advantage.

**Multi-organization data entry.** Partner organizations contribute data via CSV uploads rather than direct database connections. The ETL pipeline (CSV → Python → DynamoDB) does not require SQL knowledge from data contributors and avoids the need to manage database users and permissions across institutions.

**Scale and cost.** At the data volumes typical of this project (hundreds to low thousands of samples), DynamoDB's PAY_PER_REQUEST billing costs less than a continuously running RDS instance, with no minimum fee.

**Where SQL would be preferable.** If this project were to scale significantly — requiring complex multi-table aggregations, full-text search, or integration with BI tools that expect SQL — migrating to PostgreSQL (e.g., via AWS RDS or Aurora) would be worth revisiting. The star schema used here maps cleanly to a relational model if that transition becomes necessary.

---

## Database Architecture

This project uses **AWS DynamoDB** — a fully managed NoSQL cloud database — to store and serve microparticle data collected across partner organizations. The database uses a **star schema** with five tables:

```
                        ┌─────────────┐
                        │    Site     │  ← Hub table: location, waterbody, coordinates
                        └──────┬──────┘
               ┌───────────────┼───────────────┐
               ▼               ▼               ▼
        ┌─────────┐      ┌──────────┐    ┌──────────┐
        │  Water  │      │ Sediment │    │  Animal  │
        └────┬────┘      └────┬─────┘    └────┬─────┘
             └────────────────┼───────────────┘
                              ▼
                        ┌──────────┐
                        │   FTIR   │  ← Spectroscopic confirmation (subset of samples)
                        └──────────┘
```

| Table | Primary Key | Description |
|-------|-------------|-------------|
| `Site` | `site_id` | Sampling location metadata (waterbody, coordinates, date range, partner org) |
| `Water` | `sample_id` | Water sample microparticle counts and characteristics |
| `Sediment` | `sample_id` | Sediment sample microparticle counts and characteristics |
| `Animal` | `sample_id` | Bivalve/animal sample microparticle counts and characteristics |
| `FTIR` | `ftir_id` | Micro-FTIR spectroscopy results: polymer ID, confirmation status |

All sample tables include `site_id` as a foreign key linking back to the `Site` table. The `FTIR` table links to samples via `sample_id` and `sample_type`.

See [`schema/README.md`](schema/README.md) for full attribute lists, key design decisions, and access pattern rationale.

---

## Pipeline Structure

### ETL: Raw Data → DynamoDB

| Step | Script | Description |
|------|--------|-------------|
| 1 | `schema/dynamodb_schema.json` | Define table structure, keys, and indexes |
| 2 | `database/table_setup.py` | Provision all 5 tables in AWS DynamoDB |
| 3 | `database/table_upload.py` | Clean and batch-upload CSVs (500 rows/batch) |
| 4 | `database/view_dynamodb.py` | Verify data load via console or boto3 |
| 5 | `database/crud_operations.py` | Ongoing data management (add, edit, delete records) |
| 6 | `database/data_extraction.py` | Query and extract data for analysis |
| 7 | `database/joining_tables.py` | Assemble joined datasets (e.g., Site + Animal + FTIR) |

### Analysis

| Step | Script | Description |
|------|--------|-------------|
| 8 | `analysis/R/microparticles_analysis.R` | Primary statistical analysis in R |
| 9 | `analysis/python/microparticles_analysis.py` | Python conversion for reproducibility and pipeline integration |
| 10 | `figures/report_figures.R` | Generate all publication-quality figures |

### Dashboard

| Component | Location | Description |
|-----------|----------|-------------|
| Options discussion | `dashboard/README.md` | Cost, schema fit, and stakeholder accessibility comparison |
| React app | `dashboard/react/App.jsx` | JavaScript framework for interactive web dashboard |
| Streamlit app | `dashboard/streamlit/app.py` | Python framework for rapid data exploration dashboard |

---

## Requirements

### Python Version
Python ≥ 3.9 recommended.

### Python Packages

```bash
pip install boto3 pandas numpy matplotlib seaborn streamlit python-dotenv
```

### R Version
R ≥ 4.2.0 recommended.

### R Packages

```r
install.packages(c(
  "tidyverse", "lubridate",
  "ggplot2", "ggpubr", "gridExtra", "viridis",
  "sf", "rnaturalearth",
  "vegan", "FSA", "DescTools"
))
```

### AWS Configuration

This project requires AWS credentials with DynamoDB read/write access. Credentials are **never stored in this repository**. Configure via:

```bash
aws configure
# or
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_DEFAULT_REGION=ca-central-1
```

See [`database/README.md`](database/README.md) for full IAM permission requirements.

---

## Data

Input datasets are not included in this repository. See [`data/README.md`](data/README.md) for full descriptions, column definitions, and access instructions for all required datasets, including:

- Visually identified microparticle data (water, sediment, animal matrices) — multiple partner organizations
- Micro-FTIR spectroscopy results — polymer identification and confirmation status
- Site metadata — waterbody locations, coordinates, sampling dates, partner attribution
- Saint John Harbour and Wolastoq/Saint John River watershed spatial boundaries

Data were contributed by: University of New Brunswick Saint John, Huntsman Marine Science Centre, Mount Allison University, Coastal Action, ACAP Saint John, and the Passamaquoddy Recognition Group.

---

## Partners

This project is a collaboration across the following organizations:

| Organization | Location |
|-------------|----------|
| University of New Brunswick | Saint John, NB |
| Huntsman Marine Science Centre | St. Andrews, NB |
| Mount Allison University | Sackville, NB |
| Coastal Action | Mahone Bay, NS |
| ACAP Saint John | Saint John, NB |
| Passamaquoddy Recognition Group | St. Stephen, NB |
| Dalhousie University | Halifax, NS |

---

## Placeholders

Scripts use generic placeholder names that must be replaced with project-specific values. See individual script headers for details.

| Placeholder | Replace with |
|-------------|-------------|
| `"path/to/..."` | Local or S3 file paths to input CSVs |
| `YOUR_REGION` | AWS region (e.g., `ca-central-1`) |
| `YOUR_TABLE_NAME` | DynamoDB table name (e.g., `Site`, `Water`) |
| `sample_type_here` | Sample matrix (`water`, `sediment`, `animal`) |

---

## Citation

Citations will be added once the government report and peer-reviewed manuscript are finalized.

---

## License

This code is released under the [MIT License](https://opensource.org/licenses/MIT). Data contributed by partner organizations are subject to their respective data sharing agreements.

---

## Contact

For questions about the analysis or database infrastructure please contact Samantha McGarrigle (samantha.a.mcgarrigle@gmail.com).

---

*microparticles_saint_john — Samantha McGarrigle*
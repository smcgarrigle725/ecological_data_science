# Analysis — Python

Python conversion of `analysis/R/microparticles_analysis.R`.

## Files

| Script | Description |
|--------|-------------|
| `microparticles_analysis.py` | Full analysis pipeline — data loading, merging, concentration normalization, nonparametric tests, GLMs, FTIR summaries |

## Usage

```python
# Run the full pipeline
python microparticles_analysis.py

# Or import and call individual functions
from microparticles_analysis import load_data, build_merged_datasets, run_analysis

results = run_analysis(
    sites_path    = "path/to/Site.csv",
    animal_path   = "path/to/Animal.csv",
    sediment_path = "path/to/Sediment.csv",
    water_path    = "path/to/Water.csv",
    ftir1_path    = "path/to/FTIR_compound_summary.csv",
    ftir2_path    = "path/to/FTIR_shape_summary.csv",
)

# Access results
animal_site  = results["datasets"]["animal_site"]
animal_long  = results["long"]["animal_long"]
models       = results["models"]
```

## Requirements

```bash
pip install pandas numpy scipy statsmodels scikit-posthocs
```

## R → Python translation notes

| R | Python | Notes |
|---|--------|-------|
| `as.factor()` | `pd.Categorical()` | Used for plot axis ordering; not required for modelling |
| `glm.nb()` | `statsmodels NegativeBinomial` | Log link, same as R default |
| `kwAllPairsConoverTest()` | `scikit_posthocs.posthoc_dunn()` | Dunn's test with Bonferroni correction is the standard Python equivalent; Conover's exact test is not widely available in Python |
| `glht()` Tukey | `statsmodels pairwise_tukeyhsd()` | Applied to group means |
| `gather()` | `pd.melt()` | Wide → long reshape |
| `merge()` | `pd.DataFrame.merge()` | Suffixes `_x`/`_y` instead of R's `.x`/`.y` — KEEP_COLS use underscores accordingly |
| `distinct()` | `drop_duplicates()` | First-occurrence site metadata row for averages join |
| `left_join()` | `.merge(how="left")` | Default in `site_averages()` |

## Data inputs

Replace `"path/to/..."` placeholders in `run_analysis()` with your local CSV paths, or files exported from DynamoDB:

```python
from database.data_extraction import export_to_csv

export_to_csv("Site",     "data/Site.csv")
export_to_csv("Animal",   "data/Animal.csv")
export_to_csv("Sediment", "data/Sediment.csv")
export_to_csv("Water",    "data/Water.csv")
export_to_csv("FTIR",     "data/FTIR.csv")
```
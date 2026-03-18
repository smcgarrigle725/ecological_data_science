# Analysis — R

This directory contains the primary statistical analysis pipeline in R.

## Files

| Script | Description |
|--------|-------------|
| `microparticles_analysis.R` | Full analysis pipeline — data loading, type coercion, site filtering, merging, concentration normalization, nonparametric tests, GLMs |

## Usage

```r
source("microparticles_analysis.R")
```

Running this script loads all analysis objects into the R environment. These are then available to `figures/report_figures.R`.

## Key objects produced

| Object | Description |
|--------|-------------|
| `animal_site` | All watershed animal samples merged with site metadata |
| `bivalve_site` | Bivalve-only subset merged with site metadata |
| `bivalve_sjh_site` | Saint John Harbour bivalves only |
| `sediment_site` | Watershed sediment samples merged with site metadata |
| `water_site` | Watershed water samples merged with site metadata |
| `*_long` | Long-format versions of each merged DataFrame for plotting |
| `*_site_avg` | Site-level mean concentrations per year |
| `animal_models`, `bivalve_models`, etc. | Named lists of best-fit GLMs per MP type |
| `FTIR1_pct`, `FTIR2_pct` | FTIR summary tables with percentage columns |

## Required packages

```r
install.packages(c(
  "tidyverse", "dplyr", "openxlsx",
  "ggplot2", "ggpubr", "sf", "rnaturalearth", "rnaturalearthdata",
  "ggspatial", "ggrepel", "ggthemes", "RColorBrewer",
  "nlme", "lme4", "tweedie",
  "multcomp", "PMCMRplus", "lmerTest",
  "DHARMa", "MuMIn", "AICcmodavg",
  "pscl", "car", "MASS", "glmmTMB"
))
```

## Data inputs

Replace `"path/to/..."` placeholders at the top of the script with paths to your local CSVs, or files exported from DynamoDB using:

```python
# database/data_extraction.py
export_to_csv("Site",     "../data/Site.csv")
export_to_csv("Animal",   "../data/Animal.csv")
export_to_csv("Sediment", "../data/Sediment.csv")
export_to_csv("Water",    "../data/Water.csv")
export_to_csv("FTIR",     "../data/FTIR.csv")
```

## Notes on GLM family selection

Negative Binomial (`glm.nb`) consistently outperformed Gaussian and Poisson families by AIC across all MP types and matrices. `sphere_g` is excluded from GLMs in all matrices — near-zero inflation across groups causes NB theta estimation to fail.
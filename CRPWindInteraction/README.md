# Grassland-Obligate Bird Species Abundance Modeling: Wind Energy and Conservation Reserve Program Effects

---

## Associated Publications

This repository contains code supporting two related manuscripts. Links and abstracts will be added upon publication.

---

### Manuscript 1 — Wind Energy × CRP Interaction Analysis
*(code in this repository: `interaction_analysis_pipeline.ipynb`)*

**Title:** Evaluating interactive effects of the Conservation Reserve Program and wind energy infrastructure on grassland bird abundance in the United States
**Authors:** Samantha A. McGarrigle<sup>1*</sup>, Ellery Vaughn Lassiter<sup>1</sup>, Karen Maguire<sup>2</sup>, Rich Iovanna<sup>3</sup>, Jay Diffendorfer<sup>4</sup>, Anthony Lopez<sup>5</sup>, Kyle Reed<sup>2</sup>, Courtney Duchardt<sup>1,6</sup>, Scott Loss<sup>1</sup>
**Affiliations:**
<sup>1</sup> Department of Natural Resource Ecology and Management, Oklahoma State University, Stillwater, Oklahoma, USA
<sup>2</sup> USDA Economic Research Service, U.S. Department of Agriculture, Kansas City, Missouri, USA
<sup>3</sup> USDA Farm Production and Conservation Mission Area, Economic and Policy Analysis Division, Washington D.C., USA
<sup>4</sup> United States Geological Survey, Geosciences and Environmental Change Science Center, Lakewood, CO, USA
<sup>5</sup> U.S. Department of Energy, National Renewable Energy Laboratory, Golden, Colorado, USA
<sup>6</sup> School of Natural Resources and the Environment, University of Arizona, Tucson, Arizona, USA
<sup>*</sup> Corresponding author
**Journal:** [Journal Name]  
**Article page:** [Add link here when available]  
**DOI:** [Add DOI here when available]

**Abstract:**

> The extent of grasslands has declined globally, causing significant declines of grassland-obligate species including birds. Grassland birds are threatened by multiple factors including grassland conversion to cropland and development including energy infrastructure. In the United States, the federal Conservation Reserve Program (CRP) provides financial incentives for agricultural landowners to convert marginal cropland to vegetative covers, including grassland, making it a key approach to recover grasslands. However, given the high percentage of wind turbines near CRP land, it is critical to determine if wind energy and CRP interact to affect grassland birds. We used generalized additive models to assess interacting effects of wind and CRP on abundances of 27 grassland-obligate bird species across their breeding ranges in the continental U.S. using community science eBird data. We found associations between bird relative abundances and interactions containing wind and CRP variables, suggesting wind energy development placed close to CRP fields could dampen benefits of CRP for some species. These results indicate that decisions about where to install wind energy infrastructure that incorporate information about the presence of CRP land may reduce adverse effects of wind energy on grassland birds. This study provides information that can help maximize benefits of CRP while allowing for environmentally friendly development of renewable energy.  

---

### Manuscript 2 — Wind Energy Only Analysis
*(code in a separate repository)*

**Title:** Using eBird citizen science data to examine associations between wind energy development and grassland bird abundance across the United States
**Authors:** Samantha A. McGarrigle<sup>1*</sup>, Ellery Vaughn Lassiter<sup>1</sup>, Karen Maguire<sup>2</sup>, Rich Iovanna<sup>3</sup>, Jay Diffendorfer<sup>4</sup>, Courtney Duchardt<sup>1,5</sup>, Scott Loss<sup>1</sup>
**Affiliations:**
<sup>1</sup> Department of Natural Resource Ecology and Management, Oklahoma State University, Stillwater, Oklahoma, USA
<sup>2</sup> USDA Economic Research Service, U.S. Department of Agriculture, Kansas City, Missouri, USA
<sup>3</sup> USDA Farm Production and Conservation Mission Area, Economic and Policy Analysis Division, Washington D.C., USA
<sup>4</sup> United States Geological Survey, Geosciences and Environmental Change Science Center, Lakewood, CO, USA
<sup>5</sup> School of Natural Resources and the Environment, University of Arizona, Tucson, Arizona, USA
<sup>*</sup> Corresponding author
**Journal:** [Journal Name]  
**Article page:** [Add link here when available]  
**DOI:** [Add DOI here when available]  
**Code repository:** `wind_analysis_pipeline.ipynb`

**Abstract:**

> The extent of grasslands has declined globally, causing significant declines of grassland-obligate species including birds. In addition to grassland conversion to cropland, grassland birds are threatened by multiple factors including development of energy infrastructure. Direct and indirect effects of wind energy on birds have been studied extensively; however, few large-scale, range-wide analyses of potential impacts on bird abundances exist. We assessed associations between wind energy development and relative abundances of 27 grassland-obligate bird species across their breeding ranges in the continental U.S. We examined eBird data, using generalized additive models, and considering potential spatial scale-dependent effects by conducting analyses at two spatial scales (i.e., using hexagonal grid cells with radii of 4.5 km and 1.5 km). For 22 of 27 species of grassland-obligate birds that we studied, there were associations between relative abundance and characteristics and/or amount of wind energy infrastructure at one or both spatial scales. While some variables (i.e. turbine rotor swept area, energy capacity, and turbine presence) were often negatively associated with bird relative abundances, other variables, such as number of turbines, had positive associations with some bird species. Further, the nature of these associations with wind turbines varied among species. For example, at the larger spatial scale, no wind energy variables were associated with relative abundance of Buteo swainsoni (Swainson’s Hawk), but at the smaller scale, both wind turbine rotor swept area and turbine capacity were inversely associated with relative abundance of this species. In contrast, Pooecetes gramineus (Vesper Sparrow) had well supported models for turbine rotor swept area at both spatial scales. Our findings demonstrate that bird responses to wind energy are highly species-specific, thus guidance for bird-friendly development of wind energy may need to be updated to take this into account, particularly for species of conservation concern in areas of proposed and existing development.  

---

## Overview

This repository contains the complete R analysis pipeline for Manuscript 1 (above). The workflow models species abundance in relation to wind energy infrastructure and Conservation Reserve Program (CRP) enrollment, using citizen science data from eBird and spatially matched covariates.

The pipeline proceeds from raw eBird data extraction through spatial filtering, covariate joining, model selection, diagnostics, and figure generation. All code is provided as a Jupyter Notebook (R kernel) to facilitate step-by-step reproducibility.

---

## Repository Contents

```
.
├── README.md
└── interaction_analysis_pipeline.ipynb     # Full R analysis notebook (15 parts)
```

---

## Notebook Structure

| Part | Description |
|------|-------------|
| 1 | eBird data extraction, zero-filling, effort filtering |
| 2 | Spatial clipping to breeding range, hexagonal grid assignment, annual subsampling |
| 3 | Joining land cover, wind turbine, and CRP datasets; control/experimental classification |
| 4 | Wind variable categorization (presence/absence, age, height, rotor area, capacity) |
| 5 | Correlation matrix to assess multicollinearity |
| 6 | Z-score standardization and 80/20 train/test split |
| 7 | Distribution family evaluation via null GAMs (Poisson, NB, ZIP, ZINB) |
| 8 | Univariate screening of effort and land cover covariates |
| 9 | Wind variable screening against spatial base model |
| 10 | CRP variable screening against spatial base model |
| 11 | Full wind-only GAM candidates (with effort + land cover) |
| 12 | Full CRP-only GAM candidates (with effort + land cover) |
| 13 | Combined wind + CRP models (additive and interaction structures) |
| 14 | Top model diagnostics (variance components, ANOVA, residual plots) |
| 15 | Figure generation (predicted abundance vs. focal predictors) |

---

## Requirements

### R Version
R ≥ 4.2.0 recommended.

### R Packages
Install all required packages with:

```r
install.packages(c(
  "tidyverse", "lubridate",
  "sf", "raster", "dggridR", "rnaturalearth",
  "ggpubr", "gridExtra", "viridis", "fields", "corrplot",
  "mgcv", "pscl", "MASS", "FSA", "fitdistrplus", "hglm", "grplasso",
  "AICcmodavg", "MuMIn", "DescTools", "pdp",
  "auk", "ebirdst"
))

# zigam is not on CRAN — install from GitHub:
# devtools::install_github("dill/zigam")
```

### Jupyter with R Kernel
To run this notebook, you need Jupyter and the R kernel (`IRkernel`):

```r
install.packages("IRkernel")
IRkernel::installspec()
```

Then launch with:
```bash
jupyter notebook analysis_pipeline.ipynb
```

Alternatively, the `.ipynb` file can be opened in [VS Code](https://code.visualstudio.com/) with the Jupyter extension, or viewed (non-interactively) directly on GitHub.

---

## Data Requirements

This notebook requires several input datasets that are **not included** in this repository due to size and licensing constraints:

| Dataset | Source | Notes |
|---------|--------|-------|
| eBird Basic Dataset (EBD) | [Cornell Lab of Ornithology](https://ebird.org/data/download) | Requires free registration; filter to target species |
| Species range maps | [eBird Status & Trends](https://science.ebird.org/en/status-and-trends) | Accessed via `ebirdst` package |
| US border shapefile | [U.S. Census Bureau TIGER/Line](https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html) | Cartographic boundary files |
| Land cover (PLAND) | [NLCD](https://www.mrlc.gov/) or derived product | Proportion of landscape by class per grid cell |
| Wind turbine data | [USGS Wind Turbine Database](https://www.sciencebase.gov/catalog/item/57bdfd8fe4b03fd6b7df5ff9) | Pre-processed to cell-year summaries |
| CRP enrollment data | [USDA Farm Service Agency](https://www.fsa.usda.gov/programs-and-services/conservation-programs/conservation-reserve-program/) | Requires custom spatial processing |

Update all file paths in the notebook (marked `"path/to/..."`) to match your local directory structure before running.

---

## Placeholders to Replace

Several variable names in the notebook are generic and must be replaced with your specific covariate names after completing the univariate screening steps (Parts 9–10):

| Placeholder | Replace with |
|-------------|-------------|
| `species_name_here` | eBird species name string (e.g., `"Henslow's Sparrow"`) |
| `wind_variable` | Best-supported wind metric (e.g., `WindCount`, `WindPA`) |
| `crp_variable` | Best-supported CRP metric (e.g., `CRP_area`, `Hab_PercentGrassland`) |

---

## Citation

If you use or adapt this code, please cite the associated article:

> [Author Names] ([Year]). [Full article title]. *[Journal Name]*, [Volume]([Issue]), [Pages]. [DOI]

---

## License

This code is released under the [MIT License](https://opensource.org/licenses/MIT). Data products derived from eBird and other sources are subject to their respective terms of use.

---

## Contact

For questions about the analysis, please contact [corresponding author name] at [email address].

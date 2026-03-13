# Grassland-Obligate Bird Species Abundance Modeling: Wind Energy and Conservation Reserve Program Effects

---

This repository contains the complete R analysis pipelines supporting two related manuscripts on grassland bird responses to wind energy infrastructure and Conservation Reserve Program (CRP) enrollment across the continental United States. Both studies model species relative abundance using citizen science eBird data and generalized additive models (GAMs) at continental scale, covering 27 grassland-obligate bird species across their breeding ranges.

---

## Associated Publications

This repository contains code supporting two related manuscripts. Links and abstracts will be added upon publication.

---

### Manuscript 1 — Wind Energy × CRP Interaction Analysis
*(code in this repository: `interaction_analysis_pipeline.ipynb`)*

**Title:** Evaluating interactive effects of the Conservation Reserve Program and wind energy infrastructure on grassland bird abundance in the United States  
**Authors:** Samantha A. McGarrigle<sup>1\*</sup>, Ellery Vaughn Lassiter<sup>1</sup>, Karen Maguire<sup>2</sup>, Rich Iovanna<sup>3</sup>, Jay Diffendorfer<sup>4</sup>, Anthony Lopez<sup>5</sup>, Kyle Reed<sup>2</sup>, Courtney Duchardt<sup>1,6</sup>, Scott Loss<sup>1</sup>  
**Journal:** [Journal Name]  
**Article page:** [Add link here when available]  
**DOI:** [Add DOI here when available]

**Affiliations:**  
<sup>1</sup> Department of Natural Resource Ecology and Management, Oklahoma State University, Stillwater, Oklahoma, USA  
<sup>2</sup> USDA Economic Research Service, U.S. Department of Agriculture, Kansas City, Missouri, USA  
<sup>3</sup> USDA Farm Production and Conservation Mission Area, Economic and Policy Analysis Division, Washington D.C., USA  
<sup>4</sup> United States Geological Survey, Geosciences and Environmental Change Science Center, Lakewood, CO, USA  
<sup>5</sup> U.S. Department of Energy, National Renewable Energy Laboratory, Golden, Colorado, USA  
<sup>6</sup> School of Natural Resources and the Environment, University of Arizona, Tucson, Arizona, USA  

<sup>\*</sup> Corresponding author

**Abstract:**

> The extent of grasslands has declined globally, causing significant declines of grassland-obligate species including birds. Grassland birds are threatened by multiple factors including grassland conversion to cropland and development including energy infrastructure. In the United States, the federal Conservation Reserve Program (CRP) provides financial incentives for agricultural landowners to convert marginal cropland to vegetative covers, including grassland, making it a key approach to recover grasslands. However, given the high percentage of wind turbines near CRP land, it is critical to determine if wind energy and CRP interact to affect grassland birds. We used generalized additive models to assess interacting effects of wind and CRP on abundances of 27 grassland-obligate bird species across their breeding ranges in the continental U.S. using community science eBird data. We found associations between bird relative abundances and interactions containing wind and CRP variables, suggesting wind energy development placed close to CRP fields could dampen benefits of CRP for some species. These results indicate that decisions about where to install wind energy infrastructure that incorporate information about the presence of CRP land may reduce adverse effects of wind energy on grassland birds. This study provides information that can help maximize benefits of CRP while allowing for environmentally friendly development of renewable energy.  

---

### Manuscript 2 — Wind Energy Only Analysis
*(code in a separate repository)*

**Title:** Evaluating interactive effects of the Conservation Reserve Program and wind energy infrastructure on grassland bird abundance in the United States  
**Authors:** Samantha A. McGarrigle<sup>1\*</sup>, Ellery Vaughn Lassiter<sup>1</sup>, Karen Maguire<sup>2</sup>, Rich Iovanna<sup>3</sup>, Jay Diffendorfer<sup>4</sup>, Courtney Duchardt<sup>1,5</sup>, Scott Loss<sup>1</sup>  
**Journal:** [Journal Name]  
**Article page:** [Add link here when available]  
**DOI:** [Add DOI here when available]

**Affiliations:**  
<sup>1</sup> Department of Natural Resource Ecology and Management, Oklahoma State University, Stillwater, Oklahoma, USA  
<sup>2</sup> USDA Economic Research Service, U.S. Department of Agriculture, Kansas City, Missouri, USA  
<sup>3</sup> USDA Farm Production and Conservation Mission Area, Economic and Policy Analysis Division, Washington D.C., USA  
<sup>4</sup> United States Geological Survey, Geosciences and Environmental Change Science Center, Lakewood, CO, USA  
<sup>5</sup> School of Natural Resources and the Environment, University of Arizona, Tucson, Arizona, USA  

<sup>\*</sup> Corresponding author

**Code repository:** `wind_analysis_pipeline.ipynb`

**Abstract:**

> The extent of grasslands has declined globally, causing significant declines of grassland-obligate species including birds. In addition to grassland conversion to cropland, grassland birds are threatened by multiple factors including development of energy infrastructure. Direct and indirect effects of wind energy on birds have been studied extensively; however, few large-scale, range-wide analyses of potential impacts on bird abundances exist. We assessed associations between wind energy development and relative abundances of 27 grassland-obligate bird species across their breeding ranges in the continental U.S. We examined eBird data, using generalized additive models, and considering potential spatial scale-dependent effects by conducting analyses at two spatial scales (i.e., using hexagonal grid cells with radii of 4.5 km and 1.5 km). For 22 of 27 species of grassland-obligate birds that we studied, there were associations between relative abundance and characteristics and/or amount of wind energy infrastructure at one or both spatial scales. While some variables (i.e. turbine rotor swept area, energy capacity, and turbine presence) were often negatively associated with bird relative abundances, other variables, such as number of turbines, had positive associations with some bird species. Further, the nature of these associations with wind turbines varied among species. For example, at the larger spatial scale, no wind energy variables were associated with relative abundance of Buteo swainsoni (Swainson’s Hawk), but at the smaller scale, both wind turbine rotor swept area and turbine capacity were inversely associated with relative abundance of this species. In contrast, Pooecetes gramineus (Vesper Sparrow) had well supported models for turbine rotor swept area at both spatial scales. Our findings demonstrate that bird responses to wind energy are highly species-specific, thus guidance for bird-friendly development of wind energy may need to be updated to take this into account, particularly for species of conservation concern in areas of proposed and existing development.  

---

## Repository Contents

```
.
├── README.md
├── interaction_analysis_pipeline.ipynb     # Full pipeline — Manuscript 1 (15 parts)
├── wind_analysis_pipeline.ipynb            # Full pipeline — Manuscript 2 (11 parts)
├── example_interaction_species.ipynb       # Worked example — interaction analysis
├── example_wind_species.ipynb              # Worked example — wind-only analysis
├── data/
│   └── README.md                           # Dataset descriptions and access instructions
└── outputs/
    └── README.md                           # Figure descriptions
```

---

## Pipeline Structure
 
### Interaction Analysis Pipeline (`interaction_analysis_pipeline.ipynb`)
*15-part workflow for Manuscript 1*
 
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
 
### Wind-Only Analysis Pipeline (`wind_analysis_pipeline.ipynb`)
*11-part workflow for Manuscript 2*
 
| Part | Description |
|------|-------------|
| 1 | eBird data extraction, zero-filling, effort filtering |
| 2 | Spatial clipping to breeding range, hexagonal grid assignment, annual subsampling |
| 3 | Joining land cover and wind turbine datasets |
| 4 | Wind variable categorization |
| 5 | Correlation matrix |
| 6 | Z-score standardization and 80/20 train/test split |
| 7 | Distribution family evaluation via null GAMs |
| 8 | Univariate screening of effort, land cover, and wind covariates |
| 9 | Full wind candidate model fitting (with effort + land cover) |
| 10 | Top model diagnostics |
| 11 | Figure generation |
 
---
 
## Requirements
 
### R Version
R ≥ 4.2.0 recommended.
 
### R Packages
 
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
 
```r
install.packages("IRkernel")
IRkernel::installspec()
```
 
```bash
jupyter notebook interaction_analysis_pipeline.ipynb
```
 
The `.ipynb` files can also be opened in VS Code with the Jupyter extension or viewed non-interactively on GitHub.
 
---
 
## Data
 
Input datasets are not included in this repository. See [`data/README.md`](data/README.md) for full descriptions, column definitions, and access instructions for all required datasets, including:
 
- eBird Basic Dataset (Cornell Lab of Ornithology)
- Species breeding range maps (eBird Status & Trends via `ebirdst`)
- US border shapefile (US Census Bureau TIGER/Line)
- Land cover PLAND summaries derived from NLCD
- USGS Wind Turbine Database (preprocessed to cell-year summaries)
- USDA CRP enrollment data (interaction analysis only)
 
Several datasets required spatial preprocessing in QGIS prior to use in R. This is documented in `data/README.md` and in the associated manuscripts.
 
---
 
## Placeholders
 
Both pipelines use generic placeholder names that must be replaced with species- and covariate-specific values before running. See the example species notebooks for worked demonstrations.
 
| Placeholder | Replace with |
|-------------|-------------|
| `species_name_here` | eBird species name string (e.g., `"Henslow's Sparrow"`) |
| `wind_variable` | Best-supported wind metric from screening (e.g., `WindCount`, `WindRSA`) |
| `crp_variable` | Best-supported CRP metric from screening (e.g., `CRP_area`, `Hab_PercentGrassland`) |
| `"path/to/..."` | Local file paths to input datasets |
 
---
 
## Citation
 
If you use or adapt this code, please cite the associated articles:
 
> [Author Names] ([Year]). [Full article title]. *[Journal Name]*, [Volume]([Issue]), [Pages]. [DOI]
 
> [Author Names] ([Year]). [Full article title]. *[Journal Name]*, [Volume]([Issue]), [Pages]. [DOI]
 
---
 
## License
 
This code is released under the [MIT License](https://opensource.org/licenses/MIT). Data products derived from eBird and other sources are subject to their respective terms of use.
 
---
 
## Contact
 
For questions about the analysis please contact Samantha McGarrigle.
 
---
 
*ecological_data_science - Samantha McGarrigle*
# Infaunal Invertebrate Community Relationships to Water Column and Sediment Abiotic Conditions

This repository contains the complete R analysis pipeline supporting one manuscript examining which water column and sediment abiotic variables drive infaunal invertebrate community composition and juvenile bivalve abundance at intertidal sites in New Brunswick, Canada. Multivariate analyses were conducted in PRIMER-e v.7 and are not reproduced here. All univariate analyses were conducted in R.

---

## Associated Publication

**Title:** Infaunal invertebrate community relationships to water column and sediment abiotic conditions  
**Authors:** Samantha A. McGarrigle<sup>1\*</sup>, Heather L. Hunt<sup>1</sup>  
**Journal:** Marine Biology  
**Volume:** 171, article number 3 (2024)  
**Open access:** Yes  
**Article page:** https://link.springer.com/article/10.1007/s00227-023-04339-x  
**DOI:** https://doi.org/10.1007/s00227-023-04339-x

**Affiliations:**  
<sup>1</sup> Department of Biological Sciences, University of New Brunswick, Saint John, NB E2L 4L5, Canada

<sup>\*</sup> Corresponding author

**Abstract:**

> Infaunal invertebrates are affected by the overlying water and the sediment in which they live. Therefore, understanding how these environmental conditions impact infauna is critical for evaluating how they may respond to future changes in these conditions due to climate change. Here, we considered which abiotic variables, salinity, sediment characteristics (i.e. mean grain size, sorting), and water column and sediment carbonate chemistry, influence infaunal invertebrate communities and juvenile bivalve abundance at intertidal sites. We used data from sites in two regions in New Brunswick, Canada with contrasting tidal regimes and oceanographic conditions, the Bay of Fundy and the Southern Gulf of St. Lawrence. We were particularly interested in bivalve recruitment due to the importance of bivalves in ecosystem services and predicted sensitivity to climate change impacts. Using data collected in 2020 and 2021, statistical modeling was done to determine which abiotic variables were potential drivers of multivariate community composition as well as species richness, total abundance, and juvenile bivalve abundance. In our modeling, we found that carbonate chemistry variables explained a large amount of variation (~7–44%) in infaunal invertebrate communities in the two regions in both our multivariate and univariate analyses. Sediment pH explained the most variation (16.9%) in the multivariate analyses for the Bay of Fundy sites. However, in the Southern Gulf of St. Lawrence, salinity explained the most variation (9.8%) in the multivariate community composition. In the univariate modeling, alkalinity, either water column or sediment, was included in all top models for all four dependent variables, suggesting the importance of this carbonate chemistry variable for bivalves and infaunal communities. Climate change is expected to have large impacts on carbonate chemistry conditions in the oceans, specifically pH, carbonate availability, and alkalinity. The influence of carbonate chemistry parameters on infaunal invertebrate communities in these regions shows the potential sensitivity these animals have to future oceanic conditions.

**Keywords:** Infaunal invertebrates · community ecology · carbonate chemistry · sediment grain size metrics

---

## Repository Contents

```
.
├── README.md
├── infaunal_community_modeling.ipynb    # Full analysis pipeline
└── data/
    └── README.md                        # Dataset descriptions and column definitions
```

---

## Study Design

- **Regions:** Bay of Fundy (4 sites: CL, LL, POCO, RH) · Southern Gulf of St. Lawrence (5 sites: LN, BRIDG, CAF, CAL, KELLY)
- **Sampling:** Bay of Fundy — monthly July–October 2020, biweekly July–October 2021; Gulf of St. Lawrence — biweekly May–August 2021
- **Abiotic variables:** Water temperature · salinity · water column alkalinity · sediment pH (at 1.5 cm depth) · sediment alkalinity · organic matter · carbonate content · mean grain size · sorting · skewness · kurtosis
- **Biotic variables:** Species richness · total abundance · total bivalve abundance (*Mya arenaria* + *Gemma gemma* + *Macoma petalum*) · *Mya arenaria* abundance
- **Sediment pH depth selection:** pH at 1.5 cm depth had the best AICc score across all univariate and multivariate models and was used to represent sediment pH in all analyses
- **Multivariate analyses:** Conducted in PRIMER-e v.7 (PERMANOVAs and DISTLM) — not reproduced in this repository

---

## Pipeline Structure

| Section | Description |
|---------|-------------|
| 1 | Setup and data loading |
| 2 | Data preparation — factor coding, region and year subsetting, bivalve species sum |
| 3 | Sediment grain size calculation — `granstat` function from `G2Sd` package |
| 4 | Spatial and temporal variation — GLMs with Site × Date, Tukey post-hoc comparisons |
| 5 | Sediment pH depth selection — single-variable LMMs for each depth, AICc comparison |
| 6 | Distribution family selection — null GLMMs compared across Gaussian, Poisson, negative binomial, ZIP, ZINB |
| 7 | Variable selection — stepwise removal from global GLMM, AICc comparison of all subsets |
| 8 | Top model comparison — AICc table, McFadden pseudo-R², residual diagnostics |
| 9 | Figures — univariate biodiversity, abiotic variables, coefficient plots |

**Variables modelled (both regions separately):**
- Total bivalve abundance (*Mya arenaria* + *Gemma gemma* + *Macoma petalum*)
- *Mya arenaria* abundance
- Species richness
- Total abundance

---

## Requirements

### R Version
R ≥ 4.2.0 recommended.

### R Packages

```r
install.packages(c(
  "dplyr", "tidyr", "ggplot2", "ggpubr", "ggthemes",
  "RColorBrewer", "dotwhisker", "broom",
  "nlme", "lme4", "lmerTest", "glmmTMB",
  "car", "multcomp", "DHARMa",
  "MuMIn", "pscl", "AICcmodavg",
  "G2Sd"
))

# broom must be installed from GitHub:
devtools::install_github("bbolker/broom")
```

### Jupyter with R Kernel

```r
install.packages("IRkernel")
IRkernel::installspec()
```

```bash
jupyter notebook infaunal_community_modeling.ipynb
```

The `.ipynb` file can also be opened in VS Code with the Jupyter extension or viewed non-interactively on GitHub.

---

## Data

Input datasets are not included in this repository. See [`data/README.md`](data/README.md) for full descriptions and column definitions for all required data files. Data were collected in 2020 and 2021 at intertidal sites in southern and eastern New Brunswick, Canada.

---

## Citation

If you use or adapt this code, please cite the associated article:

> McGarrigle, S. A., & Hunt, H. L. (2024). Infaunal invertebrate community relationships to water column and sediment abiotic conditions. *Marine Biology*, 171, 3. https://doi.org/10.1007/s00227-023-04339-x

---

## License

This code is released under the [MIT License](https://opensource.org/licenses/MIT).

---

## Contact

For questions about the analysis please contact Samantha McGarrigle.

---

*carbonate_chemistry_invertebrates/modeling - Samantha McGarrigle*
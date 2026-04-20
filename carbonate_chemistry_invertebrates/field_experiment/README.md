# Effects of Experimental Addition of Algae and Shell Hash on an Infaunal Mudflat Community

This repository contains the complete R analysis pipeline supporting one manuscript on the effects of experimental green algae and shell hash addition on sediment carbonate chemistry and the infaunal invertebrate community on an intertidal mudflat in the Bay of Fundy. Univariate analyses were conducted in R. Multivariate community composition and biological trait analyses were originally conducted in PRIMER-e v.7 and are reproduced here in R using the `vegan` package.

---

## Associated Publication

**Title:** Effects of experimental addition of algae and shell hash on an infaunal mudflat community  
**Authors:** Samantha A. McGarrigle<sup>1\*</sup>, Mia C. Francis<sup>1</sup>, and Heather L. Hunt<sup>1</sup>  
**Journal:** Estuaries and Coasts  
**Article page:** https://link-springer-com.proxy.hil.unb.ca/article/10.1007/s12237-024-01378-z 
**DOI:** https://doi-org/10.1007/s12237-024-01378-z

**Affiliations:**  
<sup>1</sup> University of New Brunswick

<sup>\*</sup> Corresponding author

**Abstract:**

> In coastal environments, eutrophication and ocean acidification both decrease pH, impacting the abiotic conditions experienced by marine life. Infaunal invertebrates are exposed to lower pH conditions than epifauna, as porewater pH is typically lower than the overlying water. We investigated the effects of altering sediment carbonate chemistry, through the addition of transplanted green algae and/or crushed shell hash, on an infaunal community. This factorial field experiment was conducted on an intertidal mudflat in the Bay of Fundy, New Brunswick, from July to September of 2020. After 1 month, sediment pH was increased across all depths (0.09 ± 0.03 pH units, or 0.84–2.5%) by the shell hash, but was not affected by the algae, while the multivariate community composition was impacted by an interaction between algae and experimental block (6.9% of variation) as well as shell hash treatment (2.7% of variation). After month 2, all responses to the treatments disappeared, likely due to tidal currents washing away some of the shell hash and algae, suggesting reapplication of the treatments is needed. Most of the variation in the community composition was explained by spatial variation in the treatment replicates among the treatment blocks (33.5% of variation). Despite the small effects of the experimental treatments on sediment carbonate chemistry, distance-based linear modeling indicated that sediment pH may be an important driver of variation in the infaunal community. Given the complexity of the processes driving sediment chemistry in coastal environments, further experiments exploring changing environmental conditions that drive infaunal marine community structure are required.

---

## Repository Contents

```
.
├── README.md
├── mudflat_community_field.ipynb    # Full analysis pipeline
└── data/
    └── README.md                    # Dataset descriptions and column definitions
```

---

## Experimental Design

- **Algae treatment (Trt_Nut):** None (0) · Low (L) · High (H)
- **Shell hash treatment (Trt_Shell):** None (0) · Low (L) · High (H)
- **Controls:** Procedural control (PC; disturbed, no addition) · Undisturbed control (UC)
- **Blocking:** 8 randomised blocks, 10 plots per block (one per treatment combination)
- **Sampling:** Month 1 (end of August 2020) · Month 2 (end of September 2020)
- **Location:** Intertidal mudflat, Lepreau, NB (45°07'51.8" N, 66°28'27.8" W)
- **UC vs PC comparison:** No significant differences detected — only PC presented in treatment analyses

**Multivariate note:** Community composition and biological trait analyses were originally conducted in PRIMER-e v.7. Section 8 of the notebook reproduces these analyses using the `vegan` package in R. P-values may differ slightly from published results due to differences in permutation scheme between `adonis2` and PRIMER-e.

---

## Pipeline Structure

| Section | Description |
|---------|-------------|
| 1 | Setup and data loading |
| 2 | Data preparation — factor coding, UC exclusion, community matrix reshaping |
| 3 | Sediment pH — GLMMs by month, UC vs PC comparison, post-hoc tests |
| 4 | Sediment characteristics — porosity, grain size, organic matter, carbonates |
| 5 | Treatment coverage — shell and algae persistence over time |
| 6 | Univariate community metrics — species richness, abundance, evenness, Shannon, Simpson |
| 7 | Individual species abundances — 10 most abundant species, months separately |
| 8 | Multivariate community composition — PERMANOVA, db-RDA, nMDS (vegan) |
| 9 | Biological trait analysis — PERMANOVA on abundance-weighted trait matrix (vegan) |
| 10 | Figures |

---

## Requirements

### R Version
R ≥ 4.2.0 recommended.

### R Packages

```r
install.packages(c(
  "dplyr", "tidyr",
  "ggplot2", "ggpubr", "ggthemes",
  "nlme", "lme4", "lmerTest", "glmmTMB",
  "car", "multcomp", "DHARMa",
  "vegan", "readxl"
))
```

### Jupyter with R Kernel

```r
install.packages("IRkernel")
IRkernel::installspec()
```

```bash
jupyter notebook mudflat_community_field.ipynb
```

The `.ipynb` file can also be opened in VS Code with the Jupyter extension or viewed non-interactively on GitHub.

---

## Data

Input datasets are not included in this repository. See [`data/README.md`](data/README.md) for full descriptions and column definitions for all required data files.

---

## Citation

If you use or adapt this code, please cite the associated article:

> McGarrigle, S. A., & Hunt, H. L. (2024). Effects of experimental addition of algae and shell hash on an infaunal mudflat community. *Estuaries and Coasts*, 47, 160–177. https://doi.org/10.1007/s12237-023-01252-4

---

## License

This code is released under the [MIT License](https://opensource.org/licenses/MIT).

---

## Contact

For questions about the analysis please contact Samantha McGarrigle.

---

*carbonate_chemistry_invertebrates/field_experiment - Samantha McGarrigle*
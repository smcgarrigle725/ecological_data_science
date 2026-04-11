# Effects of Sediment and Water Column Acidification on Benthic Invertebrates

**Domain:** Marine Ecology · Ocean Acidification  
**Data:** Laboratory experimental data — University of New Brunswick / Huntsman Marine Science Centre  
**Language:** R  

---

## Published Work

This repository contains the data and analysis code for the following peer-reviewed publication:

McGarrigle, S.A., Bishop, M.M., Dove, S.L., Hunt, H.L. (2023). Effects of sediment and water column acidification on growth, survival, burrowing behaviour, and GABAA receptor function of benthic invertebrates. *Journal of Experimental Marine Biology and Ecology*, 566, 151918.  
https://doi.org/10.1016/j.jembe.2023.151918

---

## Research Problem

Coastal benthic invertebrates experience naturally high variability in seawater and sediment pH, and anthropogenic ocean acidification is expected to further reduce pH in nearshore environments. Quantifying how water column and sediment acidification affect the behaviour and physiology of intertidal invertebrates requires controlled laboratory experiments that isolate individual environmental stressors and their interactions, and that account for the potential role of neurochemical mechanisms.

This study examines the effects of water column acidification and sediment acidification — individually and in combination — on the growth, survival, and burrowing behaviour of four intertidal invertebrate species from the Bay of Fundy, Canada. A third experiment tests whether disruption of GABAA receptors by the neuroinhibitor gabazine is the physiological mechanism underlying changes in burrowing behaviour in reduced-pH sediment.

**Central question:** Do water column acidification, sediment acidification, and GABAA receptor disruption affect the growth, survival, and burrowing behaviour of benthic invertebrates, and does the response vary taxonomically?

---

## Species

| Species | Common name | Life stage | Experiments |
|---|---|---|---|
| *Mya arenaria* | Soft-shell clam | Juvenile | Water column acidification 2017; sediment acidification 2017 |
| *Tritia obsoleta* | Mud snail | Adult | Water column acidification 2017 & 2018; sediment acidification 2017 & 2018 |
| *Corophium volutator* | Amphipod | Adult | Sediment acidification 2017 & 2018; GABAA experiment |
| *Limecola balthica* | Baltic clam | Juvenile | GABAA experiment only |

---

## Experimental Design

### Experiment 1 — Water Column Acidification (2017 & 2018)
Six-week exposure of *M. arenaria*, *T. obsoleta*, and *C. volutator* to control (pH ≈ 7.87) or reduced-pH (pH ≈ 7.65) seawater at the Huntsman Marine Science Centre, Saint Andrews, NB. Growth (shell length, wet weight) and survival were measured for *M. arenaria* (2017 only) and *T. obsoleta* (both years). The experiment was replicated in 2018 with a nested header-tank design to address lack of header-tank replication in 2017.

### Experiment 2 — Sediment Acidification (2017 & 2018)
Immediately following the water column exposure, animals were transferred to a 2×2 factorial experiment (water treatment × sediment treatment, n = 5 per cell) with control (2017 pH = 7.37 ± 0.15; 2018 pH = 7.10 ± 0.16) or acidified (2017 pH = 6.65 ± 0.19; 2018 pH = 6.48 ± 0.14) sediment. Burrowing proportion was assessed at the end of species-specific time periods (*M. arenaria* 20 min, *C. volutator* 2 h, *T. obsoleta* 4 h).

### Experiment 3 — GABAA Receptor Function (2017)
*L. balthica*, *C. volutator*, and *T. obsoleta* were pre-exposed to gabazine (5 mg L⁻¹) or control seawater for 30 min before placement in acidified or control sediment for 4 h. A 2×2 factorial design (sediment pH × gabazine presence, n = 5) was used per species.

---

## Approach

### 1. Data preparation
- Load and inspect 10 CSV files
- Factor coercion for treatment variables
- Arcsine-square-root transformation of burrowing proportions (`asin(sqrt(x))`)
- Log-ratio transformation of length and weight change: `log(final/initial)` per container mean

### 2. Sediment pH characterisation
- Descriptive summaries of sediment pH by treatment and depth
- Boxplot profiles confirming treatment separation at 0–4 cm depth

### 3. Water column acidification — growth and survival
- Two-sample t-tests for 2017 (one header tank per treatment)
- Linear mixed effects models with header tank as random effect for 2018
- Outcomes: log length change, log weight change, number recovered

### 4. Sediment acidification — burrowing behaviour
- Two-way ANOVAs (Water × Sediment) per species for 2017
- Linear mixed effects models (Water × Sediment, random = ~1|Rep) per species for 2018
- Tukey HSD post-hoc tests for significant effects
- Descriptive summaries by treatment combination

### 5. GABAA experiment — gabazine × sediment pH
- Two-way ANOVAs (Water × GabaPres) per species
- Tukey HSD for significant interactions
- Descriptive summaries by species × treatment combination

### 6. Assumption checking
- Shapiro-Wilk tests on model residuals
- Levene's tests for homogeneity of variance

---

## Key Results

**Growth and survival:** Reduced-pH water had minimal effects on growth and survival across species and years. The only significant effect was a reduction in shell length of *T. obsoleta* in 2017. No significant effects were detected for *M. arenaria* or for *T. obsoleta* in 2018.

**Burrowing:** Sediment acidification reduced burrowing in *T. obsoleta* (≈13%) and *C. volutator* (≈30%) in 2018. In 2017, *C. volutator* showed an interaction between water and sediment treatment; prior water column acidification increased burrowing in control sediment relative to the other treatment combinations. *M. arenaria* burrowing was unaffected by either treatment.

**GABAA mechanism:** Gabazine restored burrowing of *C. volutator* in acidified water conditions (≈30% increase), implicating GABAA receptor activation in the burrowing suppression response to acidification in this species. No gabazine effect was detected in *T. obsoleta* or *L. balthica*.

---

## Methods Summary

| Analysis | Purpose | R function |
|---|---|---|
| Two-sample t-test | Water column effects on growth/survival, 2017 | `stats::t.test` |
| Two-way ANOVA | Water × sediment effects on burrowing, 2017; gabazine × water, 2017 | `stats::aov` |
| Linear mixed effects model | Water × sediment effects with header tank random effect, 2018 | `nlme::lme` |
| Type III likelihood ratio test | Fixed effects in mixed models | `car::Anova` |
| Tukey HSD | Post-hoc comparisons for significant effects | `stats::TukeyHSD` |
| Shapiro-Wilk test | Normality of residuals | `stats::shapiro.test` |
| Levene's test | Homogeneity of variance | `car::leveneTest` |

---

## Data Files

All data files are provided in the `/data` directory.

| File | Contents |
|---|---|
| `17_burrow.csv` | 2017 burrowing counts by burrow type (Not / Partial / Complete), all species |
| `17_burrow_binary.csv` | 2017 burrowing proportions with arcsine transform, all species |
| `18_burrow.csv` | 2018 burrowing counts by burrow type, all species |
| `18_burrow_binary.csv` | 2018 burrowing proportions, all species |
| `17_burrowgaba.csv` | GABAA experiment burrowing proportions by gabazine × water treatment |
| `17_snailweisur.csv` | *T. obsoleta* survival, weight, and length per replicate — 2017 |
| `17_clamweisur.csv` | *M. arenaria* survival, weight, and length per replicate — 2017 |
| `18_snailweisur.csv` | *T. obsoleta* survival, weight, and length per replicate — 2018 |
| `17_sedpH.csv` | 2017 sediment pH by depth, treatment, and container |
| `18_sedpH.csv` | 2018 sediment pH by depth, treatment, and container |

---

## R Packages

```r
library(dplyr)    # data wrangling
library(tidyr)    # reshaping
library(ggplot2)  # visualisation
library(ggpubr)   # multi-panel figures (ggarrange)
library(ggthemes) # theme_bw extensions
library(nlme)     # linear mixed effects models (lme)
library(car)      # Type III ANOVA, Levene's test
library(broom)    # tidy model outputs
```

Install all packages with:
```r
install.packages(c("dplyr", "tidyr", "ggplot2", "ggpubr", "ggthemes", "nlme", "car", "broom"))
```

---

## Repository Structure

```
/
├── acidification_burrowing_analysis.ipynb   # Full analysis notebook (R kernel)
├── data/
│   ├── 17_burrow.csv
│   ├── 17_burrow_binary.csv
│   ├── 17_burrowgaba.csv
│   ├── 17_clamweisur.csv
│   ├── 17_snailweisur.csv
│   ├── 17_sedpH.csv
│   ├── 18_burrow.csv
│   ├── 18_burrow_binary.csv
│   ├── 18_snailweisur.csv
│   └── 18_sedpH.csv
└── README.md
```

---

## Running the Notebook

The notebook requires an R kernel in JupyterLab or VS Code. To set up:

```bash
# Install IRkernel in R
install.packages("IRkernel")
IRkernel::installspec(name = "ir_env", displayname = "R (ir_env)")
```

Place all data files in a `/data` subdirectory relative to the notebook, or update the file paths in Section 2 to match your local directory structure. Run cells sequentially from Section 1.

---

## Field Sites

Animal and sediment collection locations, Bay of Fundy, Canada:

| Site | Coordinates | Species collected |
|---|---|---|
| Mary's Point, NB | 45°43′30.1″N, 64°40′14.3″W | *T. obsoleta* |
| Little Lepreau, NB | 45°07′28.8″N, 66°28′18.0″W | *M. arenaria*, *C. volutator*, sediment |

---

## Citation

If using this code or data, please cite the published paper:

McGarrigle, S.A., Bishop, M.M., Dove, S.L., Hunt, H.L. (2023). Effects of sediment and water column acidification on growth, survival, burrowing behaviour, and GABAA receptor function of benthic invertebrates. *Journal of Experimental Marine Biology and Ecology*, 566, 151918.  
https://doi.org/10.1016/j.jembe.2023.151918

---

*academic_projects - Samantha McGarrigle*

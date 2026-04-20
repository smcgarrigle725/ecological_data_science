# Effects of Semidiurnal Water Column Acidification and Sediment Presence on Growth and Survival of the Bivalve *Mya arenaria*

This repository contains the complete R analysis pipeline supporting one manuscript on the effects of water column acidification regime and sediment presence on the growth and survival of soft-shell clam (*Mya arenaria*) in a controlled laboratory experiment. A secondary species, the amphipod *Corophium volutator*, was also included in the experiment; this analysis was retained in the dissertation but is not part of the published manuscript.

---

## Associated Publication

### Laboratory Acidification Experiment

**Title:** Effects of semidiurnal water column acidification and sediment presence on growth and survival of the bivalve *Mya arenaria*  
**Authors:** Samantha A. McGarrigle<sup>1\*</sup>, Heather Hunt<sup>1</sup> 
**Journal:** Science of the Total Environment  
**Article page:** https://www.sciencedirect.com/science/article/abs/pii/S0022098123000047?via%3Dihub
**DOI:** https://doi.org/10.1016/j.jembe.2023.151872 

**Affiliations:**  
<sup>1</sup> University of New Brunswick  

<sup>\*</sup> Corresponding author

**Abstract:**

> In coastal environments, water column pH is affected by a variety of factors that result in lower and more variable pH in comparison to the open ocean. Consequently, it is critical to integrate variability in pH into laboratory experiments to better predict the response of coastal organisms to ocean acidification. For infaunal organisms, sediment can provide refuge from the water column conditions especially in coastal environments. As such, understanding how both water column conditions and the potential buffering abilities of sediment interact can provide insight into how infaunal organisms may respond to future oceanic conditions. Effects of pH variability on juvenile soft-shell clams (Mya arenaria; 2–11 mm in shell length), an ecologically and economically important species in the Bay of Fundy, Canada, were examined in a laboratory experiment. We manipulated pH through the addition of CO2 to seawater and exposed M. arenaria to three water treatments, no CO2 addition (mean ± sd; pH = 7.95 ± 0.06), semidiurnal intermittent CO2 addition (“on” pH =7.70 ± 0.13, “off” pH = 7.90 ± 0.11), and constant CO2 addition (pH = 7.73 ± 0.13). We found that M. arenaria final shell length, three mass metrics, and survival were negatively impacted by the constant CO2 addition treatment. Growth of juvenile M. arenaria only occurred in the presence of sediment, indicating the importance of sediment to M. arenaria, although sediment did not buffer the effects of constant CO2 addition. In the presence of sediment, the semidiurnal intermittent CO2 addition treatment did not negatively impact the growth of M. arenaria, indicating that it provided the clams with a recovery period. The similar growth rates of juvenile M. arenaria burrowed in sediment in the intermittent CO2 addition and control treatments suggests that M. arenaria may not be as negatively affected by future oceanic conditions as anticipated. This study demonstrated that pH variability can alter the response of benthic invertebrates to CO2 addition and thus this type of approach should be used to study other species of invertebrates.


---

## Repository Contents

```
.
├── README.md
├── mya_arenaria_acidification.ipynb    # Full analysis pipeline
└── data/
    └── README.md                       # Dataset descriptions and column definitions
```

---

## Experimental Design

- **Water treatments:** Control · Constant CO₂ (continuous acidification) · Intermittent CO₂ (semidiurnal acidification)
- **Sediment treatments:** In sediment · Above sediment
- **Randomisation unit:** Header tank (n = 9; Header 8 excluded due to pH system failure — see notebook Section 2)
- **Duration:** Summer 2019
- **Location:** Laboratory, University of New Brunswick

---

## Pipeline Structure

| Section | Description |
|---------|-------------|
| 1 | Setup and data loading |
| 2 | Data preparation — factor coding, treatment renaming, Header 8 exclusion |
| 3 | Water and sediment chemistry — daily pH, carbonate chemistry, sediment pH |
| 4 | *Mya arenaria* growth and survival — shell length, shell width, dry weights, survival, feeding rate |
| 5 | *Corophium volutator* growth and survival — length, weight, survival (thesis only) |
| 6 | Figures |

---

## Requirements

### R Version
R ≥ 4.2.0 recommended.

### R Packages

```r
install.packages(c(
  "dplyr", "tidyr",
  "ggplot2", "ggpubr",
  "nlme", "lme4",
  "car", "multcomp", "rsq"
))
```

### Jupyter with R Kernel

```r
install.packages("IRkernel")
IRkernel::installspec()
```

```bash
jupyter notebook mya_arenaria_acidification.ipynb
```

The `.ipynb` file can also be opened in VS Code with the Jupyter extension or viewed non-interactively on GitHub.

---

## Data

Input datasets are included in this repository. See [`data/README.md`](data/README.md) for full descriptions and column definitions for all required data files.

---

## Citation

If you use or adapt this code, please cite the associated article:

> McGarrigle, S. A., & Hunt, H. L. (2023). Effects of semidiurnal water column acidification and sediment presence on growth and survival of the bivalve Mya arenaria. Journal of Experimental Marine Biology and Ecology, 562, 151872. https://doi.org/10.1016/j.jembe.2023.151872

---

## License

This code is released under the [MIT License](https://opensource.org/licenses/MIT).

---

## Contact

For questions about the analysis please contact Samantha McGarrigle.

---

*carbonate_chemistry_invertebrates/lab_experiment - Samantha McGarrigle*
# Salmon Aquaculture-Derived Nutrients and Metals in Biota from Rocky Habitats in the Bay of Fundy

This repository contains the complete R analysis pipeline supporting one manuscript examining metal contamination and aquaculture feed reliance in rocky bottom benthic communities at near and away distances from Atlantic salmon pen sites across the Bay of Fundy, New Brunswick. Species tissue chemistry (trace elements and stable isotopes) is analysed using multivariate ordination, permutation-based hypothesis testing, and stable isotope biplots to assess the spatial footprint of salmon aquaculture on five ecologically distinct bioindicator species.

---

## Associated Publication

**Title:** Salmon aquaculture-derived nutrients and metals in biota from rocky habitats in the Bay of Fundy  
**Authors:** Samantha A. McGarrigle<sup>1</sup>, Jonathan Fischer-Rush<sup>1</sup>, Heather Hunt<sup>1</sup>, Karen Kidd<sup>2</sup>  
**Journal:** [Journal Name] | **DOI:** [Add upon publication]

**Abstract:** [To be added upon manuscript completion]

**Affiliations:**  
<sup>1</sup> University of New Brunswick  
<sup>2</sup> McMaster University  

---

## Study Overview

Past studies have assessed the impact of metal and nutrient loading from salmon aquaculture, but few have examined rocky bottom habitats or quantified effects at distances greater than 200 m from salmon pens. This study deployed bio-collectors at 8 pairs of near (68–441 m) and away (260–2750 m) sites across three Bay Management Areas (BMA 1, BMA 2a, BMA 3a) in the Bay of Fundy to assess exposure to metals and nutrients in five benthic species in 2016 and 2017.

**Study species:**

| Species | Common Name | Tissue |
|---------|-------------|--------|
| *Mytilus edulis* | Blue Mussel | Whole body / muscle |
| *Ciona intestinalis* | Vase Tunicate | Whole body |
| *Homarus americanus* | American Lobster | Muscle |
| *Myoxocephalus scorpius* | Shorthorn Sculpin | Whole body / muscle |
| *Pholis gunnellus* | Rock Gunnel | Whole body / muscle |

**Variables measured:** 14 trace elements (Al, As, Cr, Cu, Fe, Mg, Mn, Ni, P, S, Sr, V, Zn, Hg) and 3 stable isotope ratios (δ¹³C, δ¹⁵N, δ³⁴S)

**Note:** Blue Mussel samples were not collected in 2016; mussel analyses are 2017 only.

---

## Repository Contents

```
.
├── README.md
├── aquaculture_stable_isotopes.ipynb    # Full analysis pipeline
├── data/
│   └── README.md                        # Dataset description and access notes
└── outputs/
    └── README.md                        # Figure descriptions
```

---

## Analysis Pipeline

The notebook (`aquaculture_stable_isotopes.ipynb`) is organised into 8 sections:

| Section | Description |
|---------|-------------|
| 1 | Setup and helper functions (`run_nmds`, `run_permanova`, `run_pairwise`, `make_biplot`, `make_element_boxplot`) |
| 2 | Data loading, factor encoding, and species × year subsetting |
| 3 | Descriptive statistics — mean ± SD per species; export to CSV |
| 4 | nMDS ordination and PERMANOVA — per species × year × variable type (elements and isotopes), run via helper function loop |
| 5 | Combined multi-panel ordination figures (all species; invertebrates only; fish only) |
| 6 | Aquaculture feed comparison — joint ordination of species tissue chemistry against feed reference values |
| 7 | Stable isotope biplots (δ¹³C × δ¹⁵N, δ¹³C × δ³⁴S, δ³⁴S × δ¹⁵N) with 40% ellipses and feed overlay |
| 8 | Elemental concentration boxplots — Near vs. Away by species, BMA, and year |

### Statistical approach

**Ordination:** Non-metric multidimensional scaling (nMDS) using Bray-Curtis dissimilarity, fitted separately for trace elements and stable isotopes per species × year combination. Environmental vectors fitted via `envfit()`.

**Hypothesis testing:** PERMANOVA (`adonis2`) testing five model structures:

| Model | Description |
|-------|-------------|
| `Location × BMA / Site_Grouping` | Interaction with spatial nesting |
| `Location + BMA / Site_Grouping` | Additive with spatial nesting |
| `Location` | Near vs. Away alone |
| `BMA / Site_Grouping` | Spatial structure only |
| `BMA` | BMA without nesting |

Pairwise PERMANOVA (`pairwise.adonis2`) is run for Location within each BMA and BMA within each Location.

**Outliers:** Three species-year-type combinations contained extreme outliers (centroid distance > 2 SD): Lobster 2016 elements, Lobster 2017 isotopes, Gunnel 2016 isotopes. These are detected and removed automatically within the nMDS helper function.

**Feed comparison:** Six aquaculture feed samples analysed for the same trace elements and isotopes are overlaid on nMDS ordinations and stable isotope biplots to assess the degree to which near-site tissue chemistry shifts toward feed signatures.

---

## Requirements

### R Version
R ≥ 4.2.0 recommended.

### R Packages

```r
install.packages(c(
  "dplyr", "tidyr",
  "ggplot2", "ggpubr", "gridExtra", "grid",
  "vegan", "pairwiseAdonis"
))
```

### Jupyter with R Kernel

```r
install.packages("IRkernel")
IRkernel::installspec()
```

```bash
jupyter notebook aquaculture_stable_isotopes.ipynb
```

The `.ipynb` file can also be opened in VS Code with the Jupyter extension or viewed non-interactively on GitHub.

---

## Data

Raw data are not included in this repository. See [`data/README.md`](data/README.md) for full dataset description and column definitions.

---

## Citation

If you use or adapt this code, please cite the associated article:

> McGarrigle, S.A., Fischer-Rush, J., Hunt, H., & Kidd, K. ([Year]). Salmon aquaculture-derived nutrients and metals in biota from rocky habitats in the Bay of Fundy. *[Journal Name]*, [Volume]([Issue]), [Pages]. [DOI]

---

## License

This code is released under the [MIT License](https://opensource.org/licenses/MIT).

---

## Contact

For questions about the analysis please contact Samantha McGarrigle.

---

*ecological_data_science - Samantha McGarrigle*

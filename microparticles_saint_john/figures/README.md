# Figures

This directory contains the R script to reproduce all publication figures.

## Files

| Script | Description |
|--------|-------------|
| `report_figures.R` | Generates all 8 report figures from analysis objects |

## Usage

```r
# Step 1: run the analysis pipeline to load all required objects
source("../analysis/R/microparticles_analysis.R")

# Step 2: generate and save all figures
source("report_figures.R")
```

Figures are saved to `../outputs/` at 300 DPI.

## Figure descriptions

| File | Description |
|------|-------------|
| `fig1_site_map.png` | Map of sampling sites across the Wolastoq/Saint John watershed, coloured by waterbody |
| `fig2_animal_boxplot.png` | MP concentration (per g tissue) by waterbody — all animal samples |
| `fig3_bivalve_boxplot.png` | MP concentration (per g tissue) by waterbody — bivalves only |
| `fig4_bivalve_sjh_species_boxplot.png` | MP concentration by species — Saint John Harbour bivalves |
| `fig5_sediment_boxplot.png` | MP concentration (per g dry weight) by waterbody — sediment |
| `fig6_water_boxplot.png` | MP concentration (per mL) by waterbody — water |
| `fig7_ftir_polymer_pie.png` | Polymer composition identified by micro-FTIR, by sample matrix |
| `fig8_ftir_shape_confirmation.png` | MP structure × plastic confirmation rate by matrix |
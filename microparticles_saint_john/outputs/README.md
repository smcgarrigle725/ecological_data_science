# Outputs

Generated outputs are **not tracked in this repository** (see `.gitignore`).

This directory is the target for all figures, exported CSVs, and model outputs produced by the analysis and figure scripts. Create the directory locally before running any scripts:

```bash
mkdir outputs
```

---

## Expected Outputs

### Figures — R (`figures/report_figures.R`)

| File | Description |
|------|-------------|
| `fig1_site_map.png` | Map of sampling sites across the Wolastoq/Saint John River watershed, coloured by waterbody |
| `fig2_animal_boxplot.png` | MP concentration (MPs/g tissue) by waterbody — all animal samples |
| `fig3_bivalve_boxplot.png` | MP concentration (MPs/g tissue) by waterbody — bivalves only |
| `fig4_bivalve_sjh_species_boxplot.png` | MP concentration by species — Saint John Harbour bivalves |
| `fig5_sediment_boxplot.png` | MP concentration (MPs/g dry weight) by waterbody — sediment |
| `fig6_water_boxplot.png` | MP concentration (MPs/mL) by waterbody — water |
| `fig7_ftir_polymer_pie.png` | Polymer composition by sample matrix (micro-FTIR) |
| `fig8_ftir_shape_confirmation.png` | MP structure × plastic confirmation rate by matrix |

### Figures — Python (`example_pipeline.ipynb`)

| File | Description |
|------|-------------|
| `fig1_site_map.png` | Site map |
| `fig2_bivalve_boxplot.png` | Bivalve MP concentration by waterbody |
| `fig3_sediment_water_boxplots.png` | Sediment and water concentrations side by side |
| `fig4_ftir_polymer.png` | FTIR polymer composition by matrix |
| `fig5_ftir_shape_confirmation.png` | MP structure × plastic confirmation by matrix |

### CSV Exports — Python (`database/data_extraction.py`)

| File | Description |
|------|-------------|
| `Site_extract.csv` | Full Site table export |
| `Animal_extract.csv` | Full Animal table export |
| `Sediment_extract.csv` | Full Sediment table export |
| `Water_extract.csv` | Full Water table export |
| `FTIR_extract.csv` | Full FTIR table export |
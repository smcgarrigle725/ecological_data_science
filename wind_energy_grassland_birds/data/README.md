# Data

The analyses in this repository require several large input datasets that are **not included** here due to file size and data licensing constraints. This file documents each required dataset, its structure, and where to obtain it.

---

## Required Datasets

### 1. eBird Basic Dataset (EBD)
**Used in:** Parts 1–2 of both pipelines  
**Source:** [Cornell Lab of Ornithology eBird Data Access](https://ebird.org/data/download)  
**Access:** Free registration required. Request the full EBD or a species-specific subset.  
**Files needed:**
- `ebd_species_raw.txt` — observation records filtered to target species
- `ebd_sampling_raw.txt` — complete checklist sampling events (required for zero-filling)

**Notes:** Filter requests to the target species and the breeding season date window (June 14 – August 3) before downloading to reduce file size. Zero-filling via `auk_zerofill()` requires the sampling file.

---

### 2. Species Breeding Range Maps
**Used in:** Part 2 of both pipelines  
**Source:** [eBird Status & Trends](https://science.ebird.org/en/status-and-trends) via the `ebirdst` R package  
**Access:** Free API key required — see `ebirdst::set_ebirdst_access_key()`  
**Files needed:**
- `species_range.gpkg` — species range polygon clipped to breeding season

**Notes:** Download via `ebirdst::load_ranges()`. Subset to `season == "breeding"` before use.

---

### 3. US Border Shapefile
**Used in:** Part 2 of both pipelines  
**Source:** [US Census Bureau TIGER/Line Files](https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html)  
**Access:** Public, no registration required  
**Files needed:**
- `US_border.shp` (and associated `.dbf`, `.prj`, `.shx` files)

**Notes:** Use the cartographic boundary file (cb_us_nation) at 5m resolution. Transform to CRS 4326 before use.

---

### 4. Land Cover — Proportion of Landscape (PLAND)
**Used in:** Part 3 of both pipelines  
**Source:** Derived from the [National Land Cover Database (NLCD)](https://www.mrlc.gov/)  
**Access:** NLCD tiles are publicly available; PLAND summaries per hexagonal grid cell require custom spatial processing in QGIS or R  
**Files needed:**
- `landcover4.5_cell_PLAND.csv` — proportion of each land cover class per cell-year at 4.5 km grain
- `landcover1.5_cell_PLAND.csv` — same at 1.5 km grain (wind-only analysis)

**Columns:** `cell_year`, `Developed`, `Cropland`, `GrassShrub`, `TreeCover`, `Water`, `Wetland`, `Barren`, `IceSnow`

**Notes:** PLAND summaries were computed by overlaying hexagonal grid cells (constructed via `dggridR`) with NLCD raster tiles in QGIS, then exported per cell-year. This preprocessing step is not scripted in the analysis pipeline.

---

### 5. USGS Wind Turbine Database
**Used in:** Parts 3–4 of both pipelines  
**Source:** [USGS Wind Turbine Database](https://www.sciencebase.gov/catalog/item/57bdfd8fe4b03fd6b7df5ff9)  
**Access:** Public  
**Files needed:**
- `WRD_foranalysis.csv` — wind turbine attributes aggregated to cell-year

**Columns:** `cell_year`, `WindCount`, `WindAge`, `WindHeight`, `WindRSA`, `WindCap`

**Notes:** Raw turbine point locations from the USGS database were spatially joined to hexagonal grid cells and summarised per cell-year (mean attribute values, turbine count). This preprocessing was performed in QGIS.

---

### 6. USDA Conservation Reserve Program (CRP) Enrollment Data
**Used in:** Parts 3 and 10–13 of the interaction analysis pipeline only  
**Source:** [USDA Farm Service Agency](https://www.fsa.usda.gov/programs-and-services/conservation-programs/conservation-reserve-program/)  
**Access:** Available via FSA data requests; some summaries available through USDA ERS  
**Files needed:**
- CRP area and landscape metrics per cell-year (custom spatial processing required)

**Columns:** `cell_year`, `seqnum`, `year`, `CRP_area`, `CRPGrass_area`, `Hab_PercentGrassland`, `Hab_PercentWetland`, `obj_PercentGrass`, `obj_PercentWetland`, `obj_PercentWildlife`, `brd_PercentAttract`, `brd_PercentNeutral`, `brd_PercentAvoid`, `CRP_largest_patch_index`, `CRP_patch_density`, `CRP_edge_density`, `CRP_contagion`, `CRPGrass_largest_patch_index`, `CRPGrass_patch_density`, `CRPGrass_edge_density`, `CRPGrass_contagion`

**Notes:** CRP field boundaries were obtained from USDA FSA and spatially processed in QGIS to compute area and landscape metrics (patch density, edge density, contagion, largest patch index) per hexagonal grid cell and year using FRAGSTATS-compatible methods.

---

## Spatial Preprocessing Note

Several datasets required spatial preprocessing in QGIS before they could be used in the R analysis pipelines. This included:

- Constructing hexagonal grid cells at two spatial grains (4.5 km and 1.5 km radius) using `dggridR` cell centroids exported from R
- Overlaying grid cells with NLCD rasters to compute PLAND summaries
- Spatially joining wind turbine point locations to grid cells
- Overlaying CRP field boundaries with grid cells and computing landscape metrics

These steps are documented in the associated manuscripts. The R pipelines begin after this spatial preprocessing is complete.

---

## File Naming Conventions

All files should be placed in this `data/` directory and paths updated in the notebook where indicated by `"path/to/..."` comments.

| Placeholder in notebook | File to provide |
|---|---|
| `"raw_data/ebd_species_raw.txt"` | eBird EBD species observation file |
| `"raw_data/ebd_sampling_raw.txt"` | eBird EBD sampling events file |
| `"shapefiles/US_border.shp"` | US Census cartographic boundary shapefile |
| `"range_maps/species_range.gpkg"` | eBird Status & Trends breeding range |
| `"path/to/landcover4.5_cell_PLAND.csv"` | NLCD PLAND at 4.5 km grain |
| `"path/to/WRD_foranalysis.csv"` | USGS wind turbine cell-year summaries |
| CRP files (interaction pipeline only) | USDA FSA CRP cell-year summaries |

---

*ecological_data_science - Samantha McGarrigle*
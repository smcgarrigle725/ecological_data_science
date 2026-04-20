# Data

The analysis in this repository requires ten input datasets that are **not included** here. This file documents each required dataset, its structure, and column definitions.

---

## Required Datasets

### 1. Clam Shell Length
**Used in:** Sections 2, 4, 6  
**File:** `2019_clam_length.csv`  
**Access:** Data were collected by the authors and are available upon reasonable request. Contact Samantha McGarrigle.

**Columns:**

| Column | Description |
|--------|-------------|
| `Timing` | Measurement timepoint: `Start` or `End` |
| `Water_Trt` | Water treatment: `Control`, `Acidified`, or `Variable` |
| `Water_Rep` | Water treatment replicate number |
| `Header` | Header tank number (1–9; Header 8 excluded in primary analysis) |
| `Sed_Trt` | Sediment treatment: `In` (in sediment) or `Out` (above sediment) |
| `Animal_Rep` | Animal replicate number within container |
| `Container` | Container identifier |
| `Individ` | Individual clam identifier |
| `Micro_Length` | Shell length measured under microscope (raw units) |
| `Length` | Shell length converted to mm |
| `Micro_Width` | Shell width measured under microscope (raw units) |
| `Width` | Shell width converted to mm |

**Notes:** Initial length measurements are in rows where `Timing == "Start"`. Final measurements are in rows where `Timing == "End"`. Water treatment values `Acidified` and `Variable` are renamed to `Constant CO2` and `Intermittent CO2` in the notebook.

---

### 2. Clam Combined Weights
**Used in:** Sections 2, 4, 6  
**File:** `2019_clam_combinedweights.csv`  
**Access:** Available upon request.

**Columns:**

| Column | Description |
|--------|-------------|
| `Timing` | Measurement timepoint: `Start` or `End` |
| `Water_trt` | Water treatment |
| `Water_Rep` | Water treatment replicate number |
| `Header` | Header tank number |
| `Sed_trt` | Sediment treatment |
| `Animal_Rep` | Animal replicate number |
| `Container` | Container identifier |
| `Indiv` | Number of individual clams in container |
| `Comb_Weight` | Combined wet weight of all clams in container (g) |
| `Survival` | Survival metric |

---

### 3. Clam Individual Weights
**Used in:** Sections 2, 4, 6  
**File:** `2019_clam_individualweights.csv`  
**Access:** Available upon request.

**Columns:**

| Column | Description |
|--------|-------------|
| `Water _Trt` | Water treatment (note: space before underscore — renamed to `Water_Trt` on load) |
| `Water_Rep` | Water treatment replicate number |
| `Header` | Header tank number |
| `Sed_Trt` | Sediment treatment |
| `Animal_Rep` | Animal replicate number |
| `Container` | Container identifier |
| `Individ` | Individual clam identifier |
| `Total_wet` | Total wet weight (g) |
| `Shell_wet` | Shell wet weight (g) |
| `Tissue_wet` | Tissue wet weight (g) |
| `Shell_dry` | Shell dry weight (g) |
| `Tissue_dry` | Tissue dry weight (g) |
| `Total_dry` | Total dry weight (g) |

**Notes:** The column header `Water _Trt` contains a space before the underscore, which R reads as `Water._Trt`. The notebook renames this to `Water_Trt` on load. The raw CSV header should be updated to `Water_Trt` to avoid confusion.

---

### 4. Clam Feeding Rate
**Used in:** Sections 2, 4, 6  
**File:** `2019_clam_feeding.csv`  
**Access:** Available upon request.

**Columns:**

| Column | Description |
|--------|-------------|
| `Water_trt` | Water treatment (includes `Blank` level in addition to three water treatments) |
| `Water_Rep` | Water treatment replicate number |
| `Header` | Header tank number |
| `Animal_Rep` | Animal replicate number |
| `Container` | Container identifier |
| `Algae_Start` | Algae cell count at start of feeding trial |
| `Algae_End` | Algae cell count at end of feeding trial |
| `Algae_Diff` | Difference in algae cell count |
| `Rate` | Rate of algae consumption (cells/minute) |

---

### 5. Corophium Length
**Used in:** Sections 2, 5, 6  
**File:** `2019_coro_length.csv`  
**Access:** Available upon request.

**Columns:**

| Column | Description |
|--------|-------------|
| `Timing` | Measurement timepoint |
| `Water_Trt` | Water treatment |
| `Water_Rep` | Water treatment replicate number |
| `Header` | Header tank number |
| `Population` | Source population (collection site) |
| `Animal_Rep` | Animal replicate number |
| `Indiv` | Individual identifier |
| `Sex` | Sex of individual |
| `Micro_Length` | Body length measured under microscope (raw units) |
| `R-U` | Measurement direction |
| `Length` | Body length converted to mm |
| `Notes` | Any notes on individual |

**Notes:** *Corophium volutator* were only measured at the end of the experiment.

---

### 6. Corophium Survival
**Used in:** Sections 2, 5, 6  
**File:** `2019_coro_survival.csv`  
**Access:** Available upon request.

**Columns:**

| Column | Description |
|--------|-------------|
| `Water_Trt` | Water treatment |
| `Header` | Header tank number |
| `Population` | Source population |
| `Animal_Rep` | Animal replicate number |
| `Container` | Container identifier |
| `Indiv_Start` | Number of individuals at start |
| `Males_Start` | Number of males at start |
| `Females_Start` | Number of females at start |
| `Indiv_End` | Number of individuals recovered at end |
| `Males_End` | Number of males recovered |
| `Females_End` | Number of females recovered |
| `Surv__All` | Overall survival (%) |
| `Surv_Males` | Male survival (%) |
| `Surv_Female` | Female survival (%) |

---

### 7. Corophium Weight
**Used in:** Sections 2, 5, 6  
**File:** `2019_coro_weight.csv`  
**Access:** Available upon request.

**Columns:**

| Column | Description |
|--------|-------------|
| `Timing` | Measurement timepoint |
| `Water_Trt` | Water treatment |
| `Water_Rep` | Water treatment replicate number |
| `Header` | Header tank number |
| `Population` | Source population |
| `Animal_Rep` | Animal replicate number |
| `Weight` | Body weight (g) |

---

### 8. Daily pH
**Used in:** Sections 2, 3, 6  
**File:** `2019_ph.csv`  
**Access:** Available upon request.

**Columns:**

| Column | Description |
|--------|-------------|
| `Date` | Measurement date |
| `Time` | Time of measurement (HHMM format) |
| `Water_Trt` | Water treatment (note: `Control` values may have a trailing space — trimmed on load) |
| `Water_Rep` | Water treatment replicate number |
| `Header` | Header tank number |
| `pH_handheld` | Raw handheld pH meter reading |
| `pH_TRIS` | pH adjusted using TRIS buffer calibration |
| `pH_controller` | pH recorded by tank controller |
| `pH_animal` | pH measured at animal level |

**Notes:** The `Water_Trt` column contains trailing spaces on some rows (e.g., `"Control "`) which are trimmed with `trimws()` on load before factor coding.

---

### 9. Sediment pH
**Used in:** Sections 2, 3  
**File:** `2019_sedpH.csv`  
**Access:** Available upon request.

**Columns:**

| Column | Description |
|--------|-------------|
| `Date` | Measurement date |
| `Time` | Time of measurement |
| `Water_Trt` | Water treatment |
| `Water_Rep` | Water treatment replicate number |
| `Header` | Header tank number |
| `pH_handheld` | Raw handheld pH reading |
| `animal` | Animal present in container |
| `sample` | Sample identifier |
| `volume` | Volume of sediment sampled |
| `sediment_pH` | Raw sediment pH measurement |
| `sed_pH_adjust` | Sediment pH adjusted for measurement artefacts |

---

### 10. Water Chemistry
**Used in:** Sections 2, 3  
**File:** `2019_waterchem.csv`  
**Access:** Available upon request.

**Columns:**

| Column | Description |
|--------|-------------|
| `Bottle` | Sample bottle identifier |
| `Sample` | Sample identifier |
| `Date` | Sampling date |
| `Water_trt` | Water treatment (note: `Variable` recoded to `Intermittent CO2` on load) |
| `Water_rep` | Water treatment replicate number |
| `Tank` | Tank number |
| `TA` | Total alkalinity (μmol/kg) |
| `TA_SD` | Total alkalinity standard deviation |
| `Sal` | Salinity (ppt) |
| `pCO2` | Partial pressure of CO₂ (μatm) |
| `pH_meas` | Measured pH |
| `temp` | Temperature (°C) |
| `pH_calc` | Calculated pH from carbonate system |
| `CO2` | Dissolved CO₂ concentration |
| `HCO3` | Bicarbonate concentration |
| `CO3` | Carbonate concentration |
| `Calcite` | Calcite saturation state (Ω) |
| `Arag` | Aragonite saturation state (Ω) |

**Notes:** The `Water_trt` column uses `Variable` for the Intermittent CO₂ treatment. This is recoded to `Intermittent CO2` on load using `dplyr::recode()` to match the other data files.

---

*carbonate_chemistry_invertebrates/lab_experiment - Samantha McGarrigle*
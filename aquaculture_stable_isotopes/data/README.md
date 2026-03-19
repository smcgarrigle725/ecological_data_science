# Data

The analysis in this repository requires one primary dataset that is **not included** here. This file documents the dataset structure and column definitions.

---

## Required Dataset

### Species Element and Isotope Data
**Used in:** All sections of `aquaculture_stable_isotopes.ipynb`  
**File:** `species_element_isotope_data.csv`  
**Access:** Data were collected by the authors and are available upon reasonable request. Contact Samantha McGarrigle.

**Dimensions:** 350 rows × 26 columns

**Sampling design:** Bio-collectors deployed at 8 pairs of near (68–441 m) and away (260–2750 m) sites across three Bay Management Areas (BMA 1, BMA 2a, BMA 3a) in the Bay of Fundy, New Brunswick. Sampling conducted in 2016 and 2017.

---

## Column Definitions

### Metadata columns (cols 1–9)

| Column | Type | Description |
|--------|------|-------------|
| `Species` | character | Common species name |
| `Position` | character | Primary or Secondary collector position |
| `Year` | integer | Sampling year (2016 or 2017) |
| `Sample_Name` | character | Unique sample identifier |
| `Site_Name` | character | Name of sampling site (16 sites) |
| `BMA` | character | Bay Management Area (BMA 1, BMA 2a, BMA 3a) |
| `Location` | character | Proximity to aquaculture pen: Near or Away |
| `Site_Grouping` | character | Site pair identifier (8 pairs; e.g. BCDI, HIMOW) |
| `TissueType` | character | Muscle, WB/Muscle (whole body/muscle), or Whole Body |

### Trace element columns (cols 10–23, units: mg/kg dry weight)

| Column | Element |
|--------|---------|
| `Al` | Aluminium |
| `As` | Arsenic |
| `Cr` | Chromium |
| `Cu` | Copper |
| `Fe` | Iron |
| `Mg` | Magnesium |
| `Mn` | Manganese |
| `Ni` | Nickel |
| `P` | Phosphorus |
| `S` | Sulfur |
| `Sr` | Strontium |
| `V` | Vanadium |
| `Zn` | Zinc |
| `Hg` | Mercury |

### Stable isotope columns (cols 24–26)

| Column | Isotope | Units |
|--------|---------|-------|
| `C13` | δ¹³C | ‰ (VPDB) |
| `N15` | δ¹⁵N | ‰ (AIR) |
| `S34` | δ³⁴S | ‰ (VCDT) |

**Notes:**
- `S34` contains 5 missing values
- Blue Mussel (*Mytilus edulis*) samples were not collected in 2016; all mussel rows are 2017
- Trace element concentrations are on a dry weight basis
- Stable isotope ratios follow standard delta notation

---

## Aquaculture Feed Reference Values

Six aquaculture feed samples (Feed A–F) analysed for the same 14 trace elements and 3 stable isotopes are included as hardcoded reference values in Section 6 of the notebook. These are used to assess whether near-site tissue chemistry shifts toward the feed chemical signature.

---

*ecological_data_science - Samantha McGarrigle*

# Data

The analysis in this repository requires several input datasets that are **not included** here. This file documents each required dataset, its structure, and column definitions.

All data files share the same column structure. The `bay_` and `gulf_` prefixed files contain region-specific subsets. The `modelR.csv` file contains all samples from both regions combined.

---

## Required Datasets

### 1–5. Main Analysis Data Files

**Files:**
- `modelR.csv` — both regions combined (used for cross-region comparisons and pH depth selection)
- `bay_reduced.csv` — Bay of Fundy samples only
- `bay_R.csv` — Bay of Fundy samples (alternate version used in modeling scripts)
- `gulf_reduced.csv` — Southern Gulf of St. Lawrence samples only
- `gulf_R.csv` — Southern Gulf of St. Lawrence samples (alternate version used in modeling scripts)

**Access:** Data were collected by the authors at intertidal sites in New Brunswick, Canada in 2020 and 2021. Available upon reasonable request. Contact Samantha McGarrigle.

**Sites:**
- Bay of Fundy: Cassidy Lane (CL), Little Lepreau Road (LL), Pocologan (POCO), Red Head Road (RH)
- Southern Gulf of St. Lawrence: Lower Newcastle (LN), Anderson Bridge (BRIDG), Cote-a-Fabien (CAF), Callander Beach (CAL), Kelly Beach (KELLY), Ryan Beach (RYAN — excluded from statistical analysis)

---

### Column Definitions

#### Sample identification

| Column | Description |
|--------|-------------|
| `Date` | Sampling date (M.DD.YY format) |
| `Date_est` | Standardised sampling date (start date used for trips split over two days) |
| `Year` | Sampling year: `2020` or `2021` |
| `Site` | Site code (see Sites above) |
| `Core` | Core identifier within sampling point |
| `Month` | Sampling month |
| `Region` | Region: `Bay` or `Gulf` |

#### Species abundances (counts per core)

| Column | Description |
|--------|-------------|
| `Nematoda spp.` | Nematoda (phylum) |
| `Clitellio arenarius` | Oligochaete worm |
| `Tubificoides benedii` | Oligochaete worm |
| `Mya arenaria` | Soft-shell clam (juvenile) |
| `Gammarus oceanicus` | Amphipod |
| `Gemma gemma` | Gem clam (juvenile) |
| `Culicidae sp. larvae` | Mosquito larvae |
| `Littorina littorea` | Common periwinkle |
| `Eteone longa` | Polychaete worm |
| `Jaera albifrons` | Isopod |
| `Cerebratulus spp.` | Ribbon worm |
| `Ostracoda spp.` | Ostracod crustacean |
| `Macoma petalum` | Balthic tellin (juvenile; formerly *Limecola balthica*) |
| `Hydrobiidae spp.` | Mud snail |
| `Mytilus edulis` | Blue mussel |
| `Hediste diversicolor` | Ragworm |
| `Gammaridae spp.` | Gammarid amphipod |
| `Streblospio benedicti` | Polychaete worm |
| `Insecta larvae` | Insect larvae |
| `Nephtys picta` | Polychaete worm |
| `Copepoda spp.` | Copepod crustacean |
| `Spio filicolnis` | Polychaete worm |
| `Polydora cornuta` | Polychaete worm |
| `Corophium volutator` | Mud shrimp amphipod |
| `Crangon septemdpinosa` | Sand shrimp |

#### Sediment pH profile (raw values per core)

| Column | Description |
|--------|-------------|
| `pH 0` | Sediment pH at surface (0 cm) |
| `pH 0.5` | Sediment pH at 0.5 cm depth |
| `pH 1.0` | Sediment pH at 1.0 cm depth |
| `pH 1.5` | Sediment pH at 1.5 cm depth — **used in all models** |
| `z_pH 1.5` | Z-score standardised sediment pH at 1.5 cm |
| `pH 2.0` | Sediment pH at 2.0 cm depth |
| `pH 2.5` | Sediment pH at 2.5 cm depth |
| `pH 3.0` | Sediment pH at 3.0 cm depth |
| `sedpH_all` | Average sediment pH across all depths (0–3 cm) |
| `sedpH_surf` | Average sediment pH at surface depths only |

#### Water column abiotic variables (raw values)

| Column | Description |
|--------|-------------|
| `temp_water` | Water temperature (°C) |
| `ztemp_water` | Z-score standardised water temperature |
| `temp_sed` | Sediment temperature (°C) |
| `salinity` | Water column salinity (PSU) |
| `zsalinity` | Z-score standardised salinity |
| `alk_water` | Water column alkalinity (μmol/kg) |
| `zalk_water` | Z-score standardised water alkalinity |

#### Sediment abiotic variables (raw values)

| Column | Description |
|--------|-------------|
| `alk_sed` | Sediment porewater alkalinity (μmol/kg) |
| `zalk_sed` | Z-score standardised sediment alkalinity |
| `org_matter` | Percent organic matter (loss on ignition at 550°C) |
| `zorg_matter` | Z-score standardised organic matter |
| `carb` | Percent carbonate matter (loss on ignition at 950°C) |
| `zcarb` | Z-score standardised carbonates |
| `mean_grain` | Mean grain size (phi scale, Folk-Ward method) |
| `zmean_grain` | Z-score standardised mean grain size |
| `sorting` | Sediment sorting coefficient (phi scale) |
| `zsorting` | Z-score standardised sorting |
| `skewness` | Sediment skewness (phi scale) |
| `zskewness` | Z-score standardised skewness |
| `kurtosis` | Sediment kurtosis (phi scale) |
| `zkurtosis` | Z-score standardised kurtosis |
| `mean_um` | Mean grain size (micrometres) |
| `sorting_um` | Sorting coefficient (micrometres) |
| `skewness_um` | Skewness (micrometres) |
| `kurtosis_um` | Kurtosis (micrometres) |
| `mud_perc` | Percent mud |
| `sand_perc` | Percent sand |

#### Univariate biodiversity metrics

| Column | Description |
|--------|-------------|
| `SpecRich` | Species richness (number of species per core) |
| `Abund` | Total abundance (number of individuals per core) |
| `Simpson` | Simpson diversity index |
| `Evenness` | Pielou's evenness (J') |
| `Shannon` | Shannon diversity index (loge) |
| `Shannon_trans` | Transformed Shannon index |
| `Gini-Simpson` | Gini-Simpson index (1 - λ) |

#### Site-level averaged abiotic variables (used in top models)

Each raw abiotic variable has a corresponding site-averaged version used in the final GLMM models. These are averaged across cores within a site-date combination.

| Column | Description |
|--------|-------------|
| `pH0_avg` – `pH3.0_avg` | Site-averaged sediment pH at each depth |
| `zpH1.5_avg` | Z-score standardised site-averaged pH at 1.5 cm |
| `sedpH_avg` | Site-averaged sediment pH (all depths) |
| `sedpHsurf_avg` | Site-averaged surface sediment pH |
| `tempwater_avg` | Site-averaged water temperature |
| `ztempwater_avg` | Z-score standardised site-averaged water temperature |
| `tempsed_avg` | Site-averaged sediment temperature |
| `sal_avg` | Site-averaged salinity |
| `zsal_avg` | Z-score standardised site-averaged salinity |
| `alkwater_avg` | Site-averaged water alkalinity |
| `zalkwater_avg` | Z-score standardised site-averaged water alkalinity |
| `alksed_avg` | Site-averaged sediment alkalinity |
| `zalksed_avg` | Z-score standardised site-averaged sediment alkalinity |
| `orgmatt_avg` | Site-averaged organic matter |
| `zorgmatt_avg` | Z-score standardised site-averaged organic matter |
| `carb_avg` | Site-averaged carbonates |
| `zcarb_avg` | Z-score standardised site-averaged carbonates |
| `meangrain_avg` | Site-averaged mean grain size |
| `zmeangrain_avg` | Z-score standardised site-averaged mean grain size |
| `sorting_avg` | Site-averaged sorting |
| `zsorting_avg` | Z-score standardised site-averaged sorting |
| `skewness_avg` | Site-averaged skewness |
| `zskewness_avg` | Z-score standardised site-averaged skewness |
| `kurtosis_avg` | Site-averaged kurtosis |
| `zkurtosis_avg` | Z-score standardised site-averaged kurtosis |
| `mud_percavg` | Site-averaged percent mud |
| `sand_percavg` | Site-averaged percent sand |

---

### Notes on Z-score Standardisation

All abiotic variables were z-score standardised before inclusion in GLMM models to account for differences in scale between variables (e.g. pH ranging 0–14 vs. alkalinity values in the hundreds of μmol/kg). Standardised variables are prefixed with `z` in column names.

### Notes on Grain Size Calculation

Mean grain size, sorting, skewness, and kurtosis were calculated from sieve data using the `granstat` function in the `G2Sd` package (Folk-Ward method). Raw sieve weight data files (`sed20a.csv`, `sed21a.csv`) were processed separately to generate the grain size columns included in the main data files.

### Notes on Sediment pH Depth

Sediment pH was measured at 0.5 cm intervals from 0 to 3 cm depth in each core. The 1.5 cm depth was selected for use in all models based on AICc comparison of single-variable LMMs and GLMMs across all depths. See notebook Section 5 for the depth selection analysis.

---

*carbonate_chemistry_invertebrates/modeling - Samantha McGarrigle*
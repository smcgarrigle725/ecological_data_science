# ecological_data_science

Analyses from peer-reviewed ecological research, presented with industry-transferable framing. Projects span multivariate community modeling, large-scale observational studies with spatial components, cloud database design, and experimental analysis.

Each project folder contains cleaned analysis code, a methods summary, and explicit notes on how the analytical approach maps to industry applications in healthcare, finance, and insurance.

> Projects will be progressively updated with parallel implementations on public industry datasets.

---

## Projects

| Folder | Description | Methods | Industry Analog |
|---|---|---|---|
| `carbonate_chemistry_invertebrates/` | Effects of sediment carbonate chemistry on infaunal invertebrate communities — Bay of Fundy | GLMMs, PERMANOVAs, dbRDA, PRIMER-e | Multivariate risk factor modeling |
| `water_column_acidification/` | Experimental effects of water column acidification on *Mya arenaria* growth and survival | ANOVAs, regression, controlled experiment design | Controlled experiment analysis & A/B testing |
| `aquaculture_stable_isotopes/` | Proximity to aquaculture and stable isotope / elemental concentrations in cobble invertebrates | nMDS, PERMANOVAs, biplots | Environmental exposure & contaminant modeling |
| `microplastics_saint_john/` | Microparticle concentrations across the Saint John River watershed; multi-org data integration and AWS cloud database | SQL, AWS DynamoDB, nonparametrics | Multi-source data pipeline & cloud database design |
| `tidal_marsh_rapid_survey/` | Evaluation of a rapid survey protocol for tidal marsh bird demographic health | Nonparametrics, data cleaning, protocol validation | QA/QC & measurement instrument validation |
| `tidal_marsh_health_index/` | Environmental index to assess tidal marsh health using bird communities | GLMMs, nonparametric analysis | Composite index development & validation |
| `wind_energy_grassland_birds/` | Wind energy and Conservation Reserve Program effects on grassland-dependent bird abundance (representative species; full study n=27) | GAMs, eBird big data, QGIS, parallel computing | Large-scale spatial impact assessment |

---

## Methods Represented

**Statistical:** GLMMs · GAMs · PERMANOVAs · distance-based RDA · nMDS · nonparametric tests · ANOVA · regression  
**Spatial:** QGIS · sf · terra · raster  
**Data Engineering:** AWS DynamoDB · Aurora · SQL · multi-source ETL  
**Languages:** R · Python · SQL

---

## Publications

All projects in this repository are associated with peer-reviewed publications or manuscripts under review. See [ORCID](https://orcid.org/0000-0002-2018-798X) for full citation list.

---

*Part of a broader portfolio. See also:
[r_methods_library](https://github.com/samantha-mcgarrigle/r_methods_library) ·
[python_methods_library](https://github.com/samantha-mcgarrigle/python_methods_library) ·
[databases](https://github.com/samantha-mcgarrigle/databases)*

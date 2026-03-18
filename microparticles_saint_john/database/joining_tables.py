"""
joining_tables.py
-----------------
Assembles joined datasets from the 5 DynamoDB tables for analysis.

Mirrors the data preparation workflow from the R analysis pipeline:
    1. Pull all tables into DataFrames via data_extraction.py
    2. Filter Site table to the Saint John River watershed waterbodies
    3. Split filtered sites by sample type (Animal, Sediment, Water)
    4. Merge sample tables with their matching site subsets on siteid
    5. Subset animal samples to bivalve species only
    6. Calculate normalized concentration columns (MPs per g tissue,
       per g dry weight, or per mL water)
    7. Calculate site-level averages per year
    8. Produce a harbour-only bivalve subset for species comparisons

All functions return pandas DataFrames. Column names match the DynamoDB
schema defined in ../schema/README.md.

Usage:
    from joining_tables import (
        get_watershed_animal_site,
        get_watershed_bivalve_site,
        get_watershed_bivalve_sjh_site,
        get_watershed_sediment_site,
        get_watershed_water_site,
        get_animal_site_averages,
        get_bivalve_site_averages,
        get_sediment_site_averages,
        get_water_site_averages,
    )

    animal_site = get_watershed_animal_site()
    bivalve_site = get_watershed_bivalve_site()

Requirements:
    pip install boto3 pandas
    data_extraction.py must be in the same directory.
"""

import pandas as pd
from data_extraction import get_table

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Waterbodies that fall within the Wolastoq/Saint John River watershed.
# Mirrors the filter applied in the R pipeline:
#   sites_sj <- sites[sites$waterbody %in% c(...), ]
WATERSHED_WATERBODIES = [
    "Saint John River",
    "Tobique River",
    "Nashwaak River",
    "Oromocto River",
    "Kennebecasis River",
    "Saint John Harbour",
]

# Bivalve species to retain in the animal subset.
# Mirrors: bivalves <- animal[animal$species_common %in% c(...), ]
BIVALVE_SPECIES = [
    "Balthic clam",
    "Blue Mussel",
    "Eastern elliptio",
    "Eastern lampmussel",
    "Freshwater pearl mussel",
    "Macoma clam",
    "Ribbed Mussel",
    "Soft Shelled Clam",
    "Soft-shell clam",
]

# Numeric columns that should be cast to float after loading from DynamoDB.
NUMERIC_ANIMAL   = ["totalmp", "fibre", "fragment", "sphere", "film",
                    "ftir_numbersent", "sampleweight", "animallength",
                    "number_animal"]
NUMERIC_SEDIMENT = ["totalmp", "fibre", "fragment", "sphere", "film",
                    "ftir_numbersent", "sampleweight_wwt"]
NUMERIC_WATER    = ["totalmp", "fibre", "fragment", "sphere", "film",
                    "ftir_numbersent", "samplevolume"]

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _to_numeric(df, cols):
    """Coerce listed columns to numeric, setting non-numeric values to NaN."""
    for col in cols:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce")
    return df


def _load_tables():
    """Pull all 5 tables from DynamoDB and return as a dict of DataFrames."""
    print("Loading tables from DynamoDB...")
    tables = {}
    for name in ["Site", "Animal", "Sediment", "Water", "FTIR"]:
        tables[name] = get_table(name)
        print(f"  {name}: {len(tables[name])} records")
    return tables


def _filter_watershed_sites(sites_df):
    """Return only sites in the SJ River watershed, split by sample type."""
    sites_sj = sites_df[sites_df["waterbody"].isin(WATERSHED_WATERBODIES)].copy()

    sites_sj_anim = sites_sj[sites_sj["sampletypes"] == "Animal"].copy()
    sites_sj_sed  = sites_sj[sites_sj["sampletypes"] == "Sediment"].copy()
    sites_sj_wat  = sites_sj[sites_sj["sampletypes"] == "Water"].copy()

    print(f"  Watershed sites — Animal: {len(sites_sj_anim)}, "
          f"Sediment: {len(sites_sj_sed)}, Water: {len(sites_sj_wat)}")

    return sites_sj_anim, sites_sj_sed, sites_sj_wat


def _add_concentration_animal(df):
    """
    Add normalized MP concentration columns for animal samples.
    Units: MPs per gram tissue (totalmp / sampleweight).
    """
    for col in ["totalmp", "fibre", "fragment", "sphere", "film"]:
        df[f"{col}_g"] = df[col] / df["sampleweight"]
    return df


def _add_concentration_sediment(df):
    """
    Add normalized MP concentration columns for sediment samples.
    Units: MPs per gram dry weight (totalmp / sampleweight_wwt).
    """
    for col in ["totalmp", "fibre", "fragment", "sphere", "film"]:
        df[f"{col}_g"] = df[col] / df["sampleweight_wwt"]
    return df


def _add_concentration_water(df):
    """
    Add normalized MP concentration columns for water samples.
    Units: MPs per mL (totalmp / samplevolume).
    Note: samplevolume is stored in litres; column name _g reflects
    the R pipeline convention (MPs per unit volume).
    """
    for col in ["totalmp", "fibre", "fragment", "sphere", "film"]:
        df[f"{col}_g"] = df[col] / df["samplevolume"]
    return df


def _site_averages(df, conc_cols, group_cols=("siteid", "year")):
    """
    Calculate mean concentration per site per year, then join back
    the first-occurrence site metadata row (mirrors the R workflow:
    summarise + distinct + left_join).

    Args:
        df (pd.DataFrame): Merged sample+site DataFrame with concentration cols.
        conc_cols (list):  Names of the _g concentration columns to average.
        group_cols (tuple): Columns to group by for averaging.

    Returns:
        pd.DataFrame: One row per site-year with averages and site metadata.
    """
    # Average concentration columns per site per year
    agg = {col: "mean" for col in conc_cols if col in df.columns}
    averages = df.groupby(list(group_cols), as_index=False).agg(agg)

    # First-occurrence site metadata row (keeps stable site-level attributes)
    distinct = df.drop_duplicates(subset=["siteid"], keep="first")

    merged = averages.merge(distinct, on="siteid", suffixes=("_avg", ""))
    print(f"  Site averages: {len(merged)} site-year rows")
    return merged


# ---------------------------------------------------------------------------
# Public join functions
# ---------------------------------------------------------------------------

def get_watershed_animal_site():
    """
    All animal samples at watershed sites, merged with site metadata.
    Numeric columns coerced; concentration columns added.

    Returns:
        pd.DataFrame: animal + site, filtered to SJ watershed.
    """
    tables = _load_tables()
    sites_anim, _, _ = _filter_watershed_sites(tables["Site"])

    animal = _to_numeric(tables["Animal"], NUMERIC_ANIMAL)
    merged = animal.merge(sites_anim, on="siteid", suffixes=("_animal", "_site"))
    merged = _add_concentration_animal(merged)
    print(f"[join] Watershed Animal + Site: {len(merged)} rows")
    return merged


def get_watershed_bivalve_site():
    """
    Bivalve-only animal samples at watershed sites, merged with site metadata.

    Returns:
        pd.DataFrame: bivalve + site, filtered to SJ watershed.
    """
    tables = _load_tables()
    sites_anim, _, _ = _filter_watershed_sites(tables["Site"])

    animal = _to_numeric(tables["Animal"], NUMERIC_ANIMAL)
    bivalves = animal[animal["species_common"].isin(BIVALVE_SPECIES)].copy()
    merged = bivalves.merge(sites_anim, on="siteid", suffixes=("_animal", "_site"))
    merged = _add_concentration_animal(merged)
    print(f"[join] Watershed Bivalve + Site: {len(merged)} rows")
    return merged


def get_watershed_bivalve_sjh_site():
    """
    Bivalve-only animal samples from Saint John Harbour sites only.
    Used for species-level comparisons within the harbour.

    Returns:
        pd.DataFrame: harbour bivalves + site.
    """
    df = get_watershed_bivalve_site()
    sjh = df[df["waterbody"] == "Saint John Harbour"].copy()
    print(f"[join] SJ Harbour Bivalve + Site: {len(sjh)} rows")
    return sjh


def get_watershed_sediment_site():
    """
    All sediment samples at watershed sites, merged with site metadata.
    Concentration columns added (MPs per g dry weight).

    Returns:
        pd.DataFrame: sediment + site, filtered to SJ watershed.
    """
    tables = _load_tables()
    _, sites_sed, _ = _filter_watershed_sites(tables["Site"])

    sediment = _to_numeric(tables["Sediment"], NUMERIC_SEDIMENT)
    merged = sediment.merge(sites_sed, on="siteid", suffixes=("_sediment", "_site"))
    merged = _add_concentration_sediment(merged)
    print(f"[join] Watershed Sediment + Site: {len(merged)} rows")
    return merged


def get_watershed_water_site():
    """
    All water samples at watershed sites, merged with site metadata.
    Concentration columns added (MPs per mL water).

    Returns:
        pd.DataFrame: water + site, filtered to SJ watershed.
    """
    tables = _load_tables()
    _, _, sites_wat = _filter_watershed_sites(tables["Site"])

    water = _to_numeric(tables["Water"], NUMERIC_WATER)
    merged = water.merge(sites_wat, on="siteid", suffixes=("_water", "_site"))
    merged = _add_concentration_water(merged)
    print(f"[join] Watershed Water + Site: {len(merged)} rows")
    return merged


# ---------------------------------------------------------------------------
# Site-average join functions
# ---------------------------------------------------------------------------

CONC_COLS = ["totalmp_g", "fibre_g", "fragment_g", "sphere_g", "film_g"]


def get_animal_site_averages():
    """
    Site-level mean MP concentrations per year for all watershed animal samples.

    Returns:
        pd.DataFrame: one row per site-year with averaged concentration columns
                      and first-occurrence site metadata.
    """
    df = get_watershed_animal_site()
    return _site_averages(df, CONC_COLS)


def get_bivalve_site_averages():
    """
    Site-level mean MP concentrations per year for watershed bivalve samples.

    Returns:
        pd.DataFrame
    """
    df = get_watershed_bivalve_site()
    return _site_averages(df, CONC_COLS)


def get_sediment_site_averages():
    """
    Site-level mean MP concentrations per year for watershed sediment samples.

    Returns:
        pd.DataFrame
    """
    df = get_watershed_sediment_site()
    return _site_averages(df, CONC_COLS)


def get_water_site_averages():
    """
    Site-level mean MP concentrations per year for watershed water samples.

    Returns:
        pd.DataFrame
    """
    df = get_watershed_water_site()
    return _site_averages(df, CONC_COLS)


# ---------------------------------------------------------------------------
# Example usage
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    print("\n=== Watershed Animal + Site ===")
    df = get_watershed_animal_site()
    print(df[["siteid", "waterbody", "species_common",
              "totalmp", "totalmp_g"]].head(5))

    print("\n=== Watershed Bivalves Only ===")
    df_biv = get_watershed_bivalve_site()
    print(df_biv[["siteid", "waterbody", "species_common",
                  "totalmp_g"]].head(5))

    print("\n=== SJ Harbour Bivalves ===")
    df_sjh = get_watershed_bivalve_sjh_site()
    print(df_sjh[["siteid", "species_common", "totalmp_g"]].head(5))

    print("\n=== Animal Site Averages ===")
    df_avg = get_animal_site_averages()
    print(df_avg[["siteid", "waterbody", "totalmp_g"]].head(5))

    print("\n=== Watershed Water + Site ===")
    df_wat = get_watershed_water_site()
    print(df_wat[["siteid", "waterbody", "samplevolume",
                  "totalmp", "totalmp_g"]].head(5))

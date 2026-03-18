"""
microparticles_analysis.py
==========================
Python conversion of analysis/R/microparticles_analysis.R

Statistical analysis of microparticle concentrations in animal, sediment,
and water samples from the Wolastoq/Saint John River watershed.

This script reproduces the analysis from:
    McGarrigle et al. (in prep.) Integration and data sharing to examine the
    fate and transport of microplastics in the Wolastoq/Saint John River watershed

Workflow:
    1.  Load packages
    2.  Load data from CSV (or CSVs exported from DynamoDB via
        database/data_extraction.py → export_to_csv())
    3.  Coerce column types
    4.  Filter sites to SJ River watershed
    5.  Merge sample tables with site metadata
    6.  Subset animal table to bivalves; harbour-only subset
    7.  Calculate normalized MP concentrations (per g tissue / dry wt / mL)
    8.  Calculate site-level averages per year
    9.  Reshape to long format for plotting
    10. Nonparametric tests: Kruskal-Wallis + Dunn post-hoc
    11. GLMs: Gaussian, Poisson, Negative Binomial (AIC selection)
    12. Tukey post-hoc comparisons via statsmodels
    13. FTIR summary tables loaded and summarized separately

R → Python notes:
    - factor()        → pd.Categorical (used for ordered plot axes; not
                        required for modelling in Python)
    - glm.nb()        → statsmodels NegativeBinomial (log link)
    - kwAllPairsConoverTest() → scikit_posthocs.posthoc_dunn()
                        (Dunn's test with Bonferroni correction is the standard
                        Python equivalent; Conover's test is not widely
                        available in Python packages)
    - glht() Tukey    → statsmodels pairwise_tukeyhsd()
    - gather()        → pd.melt()

Usage:
    python microparticles_analysis.py       # runs full pipeline, prints results
    OR import functions individually:
        from microparticles_analysis import load_data, build_merged_datasets

Requirements:
    pip install pandas numpy scipy statsmodels scikit-posthocs
"""

# =============================================================================
# 1. Imports
# =============================================================================

import warnings
import pandas as pd
import numpy as np
from scipy import stats
import statsmodels.api as sm
import statsmodels.formula.api as smf
from statsmodels.stats.multicomp import pairwise_tukeyhsd
import scikit_posthocs as sp

warnings.filterwarnings("ignore")   # suppress convergence warnings during NB fitting


# =============================================================================
# 2. Configuration constants
# =============================================================================

WATERSHED_WATERBODIES = [
    "Saint John River", "Tobique River", "Nashwaak River",
    "Oromocto River", "Kennebecasis River", "Saint John Harbour",
]

BIVALVE_SPECIES = [
    "Balthic clam", "Blue Mussel", "Eastern elliptio",
    "Eastern lampmussel", "Freshwater pearl mussel",
    "Macoma clam", "Ribbed Mussel", "Soft Shelled Clam", "Soft-shell clam",
]

CONC_COLS = ["totalmp_g", "fibre_g", "fragment_g", "sphere_g", "film_g"]

# sphere_g excluded from GLMs — near-zero in most groups, NB fails
MODEL_TYPES = ["totalmp_g", "fibre_g", "fragment_g", "film_g"]

MP_LABELS = {
    "fibre_g":    "Fibre",
    "film_g":     "Film",
    "fragment_g": "Fragment",
    "sphere_g":   "Sphere",
    "totalmp_g":  "Total",
}

WATERBODY_ORDER = [
    "Saint John River", "Tobique River", "Nashwaak River",
    "Oromocto River", "Kennebecasis River", "Saint John Harbour",
    "Annapolis Basin", "Atlantic Ocean", "Bay of Fundy", "Beaver Harbour",
    "Grand Harbour", "Gulf of St. Lawrence", "Lahave River", "Minas Basin",
    "Musquash Estuary", "Passamaquoddy Bay", "Saint Mary's Bay", "Whale Cove ",
]

# Columns to keep after merge — mirrors R KEEP_COLS vectors
ANIMAL_KEEP_COLS = [
    "siteid", "collection_organization_x", "primarycontact_x",
    "site_x", "year_x", "date", "id", "sampleid", "processingmethod",
    "species_common", "species_scientific", "number_animal",
    "sampleweight", "animallength", "tissuetype",
    "totalmp", "fibre", "fragment", "sphere", "film",
    "ftir_complete", "ftir_numbersent",
    "collection_organization_y", "primarycontact_y",
    "waterbody", "waterbodytype", "site_y",
    "latitude", "longitude", "substrate", "benthicpelagic",
]

BIVALVE_KEEP_COLS = [
    "siteid", "collection_organization_x",
    "site_x", "year_x", "date", "id", "sampleid", "processingmethod",
    "species_common", "species_scientific", "number_animal",
    "sampleweight", "animallength", "tissuetype",
    "totalmp", "fibre", "fragment", "sphere", "film",
    "ftir_complete", "ftir_numbersent",
    "collection_organization_y", "primarycontact_y",
    "waterbody", "waterbodytype", "site_y",
    "latitude", "longitude", "substrate", "benthicpelagic",
]

SEDIMENT_KEEP_COLS = [
    "siteid", "collection_organization_x", "primarycontact_x",
    "site_x", "year_x", "date", "id", "sampleid", "processingmethod",
    "sampleweight_wwt",
    "totalmp", "fibre", "fragment", "sphere", "film",
    "ftir_complete", "ftir_numbersent",
    "collection_organization_y", "primarycontact_y",
    "waterbody", "waterbodytype", "site_y",
    "latitude", "longitude", "substrate", "benthicpelagic",
    "tidaldepth", "samplestaken", "sampletypes",
]

WATER_KEEP_COLS = [
    "siteid", "collection_organization_x", "primarycontact_x",
    "site_x", "year_x", "date", "id", "sampleid", "processingmethod",
    "samplevolume",
    "totalmp", "fibre", "fragment", "sphere", "film",
    "ftir_complete", "ftir_numbersent",
    "collection_organization_y", "primarycontact_y",
    "waterbody", "waterbodytype", "site_y",
    "latitude", "longitude", "substrate", "benthicpelagic",
    "tidaldepth", "samplestaken", "sampletypes",
]


# =============================================================================
# 3. Data loading
# =============================================================================

def load_data(
    sites_path    = "path/to/Site.csv",
    animal_path   = "path/to/Animal.csv",
    sediment_path = "path/to/Sediment.csv",
    water_path    = "path/to/Water.csv",
    ftir1_path    = "path/to/FTIR_compound_summary.csv",
    ftir2_path    = "path/to/FTIR_shape_summary.csv",
):
    """
    Load all CSV files and coerce column types.
    Replace path arguments with your local file paths, or paths to CSVs
    exported from DynamoDB using database/data_extraction.py.

    Returns:
        dict with keys: sites, animal, sediment, water, ftir1, ftir2
    """
    sites    = pd.read_csv(sites_path)
    animal   = pd.read_csv(animal_path)
    sediment = pd.read_csv(sediment_path)
    water    = pd.read_csv(water_path)
    ftir1    = pd.read_csv(ftir1_path)
    ftir2    = pd.read_csv(ftir2_path)

    # --- Type coercion ---
    # Categorical (R: as.factor)
    cat_sites    = ["year", "waterbody", "waterbodytype", "site", "siteid",
                    "benthicpelagic", "tidaldepth", "sampletypes"]
    cat_animal   = ["site", "siteid", "year", "id", "sampleid",
                    "species_common", "tissuetype", "ftir_complete"]
    cat_sediment = ["site", "siteid", "year", "id", "sampleid", "ftir_complete"]
    cat_water    = ["site", "siteid", "year", "id", "sampleid", "ftir_complete"]

    for col in cat_sites:
        if col in sites.columns:
            sites[col] = sites[col].astype("category")

    for col in cat_animal:
        if col in animal.columns:
            animal[col] = animal[col].astype("category")

    for col in cat_sediment:
        if col in sediment.columns:
            sediment[col] = sediment[col].astype("category")

    for col in cat_water:
        if col in water.columns:
            water[col] = water[col].astype("category")

    # Numeric (R: as.numeric — coerce errors to NaN)
    num_cols = ["totalmp", "fibre", "fragment", "sphere", "film",
                "ftir_numbersent"]
    for df in [animal, sediment, water]:
        for col in num_cols:
            if col in df.columns:
                df[col] = pd.to_numeric(df[col], errors="coerce")

    animal["sampleweight"]   = pd.to_numeric(animal.get("sampleweight"),   errors="coerce")
    animal["animallength"]   = pd.to_numeric(animal.get("animallength"),   errors="coerce")
    animal["number_animal"]  = pd.to_numeric(animal.get("number_animal"),  errors="coerce")
    sediment["sampleweight_wwt"] = pd.to_numeric(sediment.get("sampleweight_wwt"), errors="coerce")
    water["samplevolume"]    = pd.to_numeric(water.get("samplevolume"),    errors="coerce")

    # FTIR tables
    ftir1["Matrix"]     = ftir1["Matrix"].astype("category")
    ftir1["Compound"]   = ftir1["Compound"].astype("category")
    ftir2["Matrix"]     = ftir2["Matrix"].astype("category")
    ftir2["Shape"]      = ftir2["Shape"].astype("category")
    ftir2["ParticleID"] = ftir2["ParticleID"].astype("category")

    print(f"Loaded: sites={len(sites)}, animal={len(animal)}, "
          f"sediment={len(sediment)}, water={len(water)}")

    return dict(sites=sites, animal=animal, sediment=sediment,
                water=water, ftir1=ftir1, ftir2=ftir2)


# =============================================================================
# 4–6. Build merged datasets
# =============================================================================

def build_merged_datasets(data):
    """
    Filter sites to SJ watershed, merge sample tables with site metadata,
    subset bivalves, and apply column selection.

    Args:
        data (dict): output of load_data()

    Returns:
        dict with keys: animal_site, bivalve_site, bivalve_sjh_site,
                        sediment_site, water_site, sites_sj
    """
    sites    = data["sites"].copy()
    animal   = data["animal"].copy()
    sediment = data["sediment"].copy()
    water    = data["water"].copy()

    # --- Step 4: Filter to watershed ---
    sites_sj = sites[sites["waterbody"].isin(WATERSHED_WATERBODIES)].copy()
    sites_sj["siteid"] = sites_sj["siteid"].astype(str)

    sites_sj_anim = sites_sj[sites_sj["sampletypes"] == "Animal"].copy()
    sites_sj_sed  = sites_sj[sites_sj["sampletypes"] == "Sediment"].copy()
    sites_sj_wat  = sites_sj[sites_sj["sampletypes"] == "Water"].copy()

    # --- Step 5: Merge ---
    # Note: pandas merge appends _x/_y suffixes where R appends .x/.y
    # KEEP_COLS use underscores to match pandas convention
    animal["siteid"]   = animal["siteid"].astype(str)
    sediment["siteid"] = sediment["siteid"].astype(str)
    water["siteid"]    = water["siteid"].astype(str)

    animal_site   = animal.merge(sites_sj_anim,   on="siteid", suffixes=("_x", "_y"))
    sediment_site = sediment.merge(sites_sj_sed,  on="siteid", suffixes=("_x", "_y"))
    water_site    = water.merge(sites_sj_wat,     on="siteid", suffixes=("_x", "_y"))

    # Trim to schema columns (intersect guards against missing columns)
    animal_site   = animal_site[[c   for c in ANIMAL_KEEP_COLS   if c in animal_site.columns]]
    sediment_site = sediment_site[[c for c in SEDIMENT_KEEP_COLS if c in sediment_site.columns]]
    water_site    = water_site[[c    for c in WATER_KEEP_COLS    if c in water_site.columns]]

    # --- Step 6: Bivalve subsets ---
    bivalves     = animal[animal["species_common"].isin(BIVALVE_SPECIES)].copy()
    bivalve_site = bivalves.merge(sites_sj_anim, on="siteid", suffixes=("_x", "_y"))
    bivalve_site = bivalve_site[[c for c in BIVALVE_KEEP_COLS if c in bivalve_site.columns]]

    bivalve_sjh_site = bivalve_site[
        bivalve_site["waterbody"] == "Saint John Harbour"
    ].copy()

    print(f"Merged rows — animal: {len(animal_site)}, bivalve: {len(bivalve_site)}, "
          f"bivalve_SJH: {len(bivalve_sjh_site)}, sediment: {len(sediment_site)}, "
          f"water: {len(water_site)}")

    return dict(
        sites_sj         = sites_sj,
        animal_site      = animal_site,
        bivalve_site     = bivalve_site,
        bivalve_sjh_site = bivalve_sjh_site,
        sediment_site    = sediment_site,
        water_site       = water_site,
    )


# =============================================================================
# 7. Normalized MP concentration columns
# =============================================================================

def add_concentrations(datasets):
    """
    Add normalized MP concentration columns to each merged DataFrame.
        Animal / bivalve : MPs per gram tissue      (count / sampleweight)
        Sediment         : MPs per gram dry weight   (count / sampleweight_wwt)
        Water            : MPs per mL               (count / samplevolume)

    Modifies DataFrames in place and returns the updated dict.
    """
    mp_types = ["totalmp", "fibre", "fragment", "sphere", "film"]

    def _normalize(df, denominator):
        for col in mp_types:
            if col in df.columns and denominator in df.columns:
                df[f"{col}_g"] = df[col] / df[denominator]
        return df

    datasets["animal_site"]      = _normalize(datasets["animal_site"],      "sampleweight")
    datasets["bivalve_site"]     = _normalize(datasets["bivalve_site"],     "sampleweight")
    datasets["bivalve_sjh_site"] = _normalize(datasets["bivalve_sjh_site"], "sampleweight")
    datasets["sediment_site"]    = _normalize(datasets["sediment_site"],    "sampleweight_wwt")
    datasets["water_site"]       = _normalize(datasets["water_site"],       "samplevolume")

    return datasets


# =============================================================================
# 8. Site-level averages per year
# =============================================================================

def site_averages(df, year_col="year_x"):
    """
    Calculate mean MP concentration per site per year, then join back
    first-occurrence site metadata. Mirrors R: summarise + distinct + left_join.

    Args:
        df (pd.DataFrame): merged sample+site DataFrame with _g columns.
        year_col (str):    name of the year column after merge.

    Returns:
        pd.DataFrame: one row per site-year with avg_* columns + site metadata.
    """
    conc_cols_present = [c for c in CONC_COLS if c in df.columns]
    agg = {col: "mean" for col in conc_cols_present}
    agg = {f"avg_{col}": pd.NamedAgg(column=col, aggfunc=lambda x: x.mean(skipna=True))
           for col in conc_cols_present}

    group_cols = ["siteid"]
    if year_col in df.columns:
        group_cols.append(year_col)

    averages = df.groupby(group_cols, as_index=False).agg(
        **{f"avg_{col}": (col, "mean") for col in conc_cols_present}
    )

    distinct = df.drop_duplicates(subset=["siteid"], keep="first")
    merged   = averages.merge(distinct, on="siteid", suffixes=("", "_meta"))
    return merged


# =============================================================================
# 9. Long format for plotting
# =============================================================================

def to_long(df):
    """
    Reshape concentration columns to long format for plotting.
    Equivalent to R: gather() + factor relabelling.

    Returns:
        pd.DataFrame with columns: [original cols..., 'mp_type', 'value']
        mp_type uses plain-language labels (Total, Fibre, etc.)
    """
    conc_cols_present = [c for c in CONC_COLS if c in df.columns]
    id_vars = [c for c in df.columns if c not in conc_cols_present]

    long = df.melt(id_vars=id_vars, value_vars=conc_cols_present,
                   var_name="mp_type", value_name="value")
    long["mp_type"] = long["mp_type"].map(MP_LABELS)

    # Ordered categorical for plot axis control
    long["mp_type"] = pd.Categorical(
        long["mp_type"],
        categories=["Total", "Fibre", "Film", "Fragment", "Sphere"],
        ordered=True
    )

    if "waterbody" in long.columns:
        long["waterbody"] = pd.Categorical(
            long["waterbody"],
            categories=WATERBODY_ORDER,
            ordered=True
        )

    return long


# =============================================================================
# 10. Nonparametric tests: Kruskal-Wallis + Dunn post-hoc
# =============================================================================
# R used kwAllPairsConoverTest (Conover's test). Python equivalent is
# Dunn's test with Bonferroni correction via scikit_posthocs, which is
# the standard nonparametric post-hoc in the Python ecosystem.

def run_nonparametric(df, response_vars, group_var, label):
    """
    Run Kruskal-Wallis test and Dunn post-hoc for each response variable.

    Args:
        df (pd.DataFrame):    data to test.
        response_vars (list): list of column names to test (e.g. CONC_COLS).
        group_var (str):      grouping column (e.g. "waterbody").
        label (str):          label printed to console.

    Returns:
        dict: {response_var: {"kruskal": result, "dunn": DataFrame}}
    """
    print(f"\n\n==== {label} ====")
    results = {}

    for rv in response_vars:
        print(f"\n-- {rv} --")
        sub = df[[rv, group_var]].dropna()

        if sub[group_var].nunique() < 2:
            print("  Skipped: fewer than 2 groups after dropping NaN.")
            continue

        groups = [grp[rv].values for _, grp in sub.groupby(group_var)]

        # Kruskal-Wallis
        stat, p = stats.kruskal(*groups)
        print(f"  Kruskal-Wallis H={stat:.4f}, p={p:.4f}")

        # Dunn post-hoc with Bonferroni correction
        try:
            dunn = sp.posthoc_dunn(sub, val_col=rv, group_col=group_var,
                                   p_adjust="bonferroni")
            print("  Dunn post-hoc (Bonferroni):")
            print(dunn.round(4).to_string())
            results[rv] = {"kruskal": {"H": stat, "p": p}, "dunn": dunn}
        except Exception as e:
            print(f"  Dunn test failed: {e}")
            results[rv] = {"kruskal": {"H": stat, "p": p}, "dunn": None}

    return results


# =============================================================================
# 11. GLMs: family selection by AIC, then summarize best
# =============================================================================

def fit_glms(df, response, predictor):
    """
    Fit Gaussian, Poisson, and Negative Binomial GLMs.
    Returns AIC table and model objects.

    Note on NB link function: statsmodels NegativeBinomial uses log link
    by default, consistent with R's glm.nb().

    Args:
        df (pd.DataFrame): data containing response and predictor columns.
        response (str):    dependent variable column name.
        predictor (str):   grouping variable column name.

    Returns:
        dict: {family: fitted model or None, "aic_table": pd.DataFrame}
    """
    # Drop rows where response or predictor is NaN
    sub = df[[response, predictor]].dropna().copy()

    # Ensure predictor is treated as categorical
    sub[predictor] = sub[predictor].astype(str)

    formula = f"{response} ~ C({predictor})"
    results = {}

    # Gaussian
    try:
        results["gaussian"] = smf.glm(
            formula, data=sub, family=sm.families.Gaussian()
        ).fit(disp=0)
    except Exception as e:
        print(f"  Gaussian failed: {e}")
        results["gaussian"] = None

    # Poisson
    try:
        results["poisson"] = smf.glm(
            formula, data=sub, family=sm.families.Poisson()
        ).fit(disp=0)
    except Exception as e:
        print(f"  Poisson failed: {e}")
        results["poisson"] = None

    # Negative Binomial
    try:
        results["negbin"] = smf.glm(
            formula, data=sub,
            family=sm.families.NegativeBinomial()
        ).fit(disp=0)
    except Exception as e:
        print(f"  NB failed for {response}: {e}")
        results["negbin"] = None

    # AIC table
    aic_rows = []
    for name, model in results.items():
        if model is not None:
            aic_rows.append({"family": name, "AIC": round(model.aic, 3),
                             "df": int(model.df_model + 1)})
    results["aic_table"] = pd.DataFrame(aic_rows).sort_values("AIC").reset_index(drop=True)

    return results


def summarize_best(fit_dict, response, predictor, df):
    """
    Print summary of best-fit model (NB preferred; Gaussian fallback).
    Run Tukey pairwise comparisons on the group means.

    Args:
        fit_dict (dict):   output of fit_glms().
        response (str):    response variable name.
        predictor (str):   grouping variable name.
        df (pd.DataFrame): data used for fitting.

    Returns:
        The best-fit model object.
    """
    best = fit_dict.get("negbin") or fit_dict.get("gaussian")
    if best is None:
        print(f"  No model available for {response}.")
        return None

    family = "NegativeBinomial" if fit_dict.get("negbin") else "Gaussian"
    print(f"\n--- Best model ({family}): {response} ~ {predictor} ---")
    print(best.summary2())

    # Tukey pairwise on group means (log-scale for NB, raw scale for Gaussian)
    sub = df[[response, predictor]].dropna()
    try:
        tukey = pairwise_tukeyhsd(endog=sub[response], groups=sub[predictor])
        print("\nTukey HSD pairwise comparisons:")
        print(tukey.summary())
    except Exception as e:
        print(f"  Tukey failed: {e}")

    return best


def run_all_glms(datasets):
    """
    Run GLM family selection and summarize best model for all
    matrix × MP type combinations.

    Returns:
        dict of {matrix_label: {mp_type: best_model}}
    """
    analyses = {
        "animal":      (datasets["animal_site"],      "waterbody"),
        "bivalve":     (datasets["bivalve_site"],     "waterbody"),
        "bivalve_sjh": (datasets["bivalve_sjh_site"], "species_common"),
        "sediment":    (datasets["sediment_site"],    "waterbody"),
        "water":       (datasets["water_site"],       "waterbody"),
    }

    all_models = {}
    for label, (df, predictor) in analyses.items():
        print(f"\n\n===== GLMs: {label} ~ {predictor} =====")
        all_models[label] = {}
        for rv in MODEL_TYPES:
            fits = fit_glms(df, rv, predictor)
            print(f"\nAIC table — {rv}:")
            print(fits["aic_table"].to_string(index=False))
            best = summarize_best(fits, rv, predictor, df)
            all_models[label][rv] = best

    return all_models


# =============================================================================
# 12. FTIR summaries
# =============================================================================

def build_ftir_summaries(ftir1, ftir2):
    """
    Calculate percentage breakdowns for FTIR compound and shape tables.

    Returns:
        ftir1_pct (pd.DataFrame): compound % per matrix, with label column
        ftir2_pct (pd.DataFrame): shape × type % per matrix
    """
    # Compound percentages by matrix
    ftir1_pct = ftir1.copy()
    ftir1_pct["Percent"] = ftir1_pct.groupby("Matrix")["Count"].transform(
        lambda x: x / x.sum() * 100
    )
    ftir1_pct["Label"] = ftir1_pct["Percent"].apply(
        lambda p: f"{round(p)}%" if p > 3 else ""
    )

    # Recode ParticleID: Plastic → Artificial, Nonplastic → Natural
    ftir2_pct = ftir2.copy()
    ftir2_pct["Type"] = ftir2_pct["ParticleID"].map(
        {"Plastic": "Artificial", "Nonplastic": "Natural"}
    )
    ftir2_pct["Type"] = pd.Categorical(
        ftir2_pct["Type"], categories=["Natural", "Artificial"], ordered=True
    )
    ftir2_pct["Percent"] = ftir2_pct.groupby(["Matrix", "Shape"])["Count"].transform(
        lambda x: x / x.sum() * 100
    )

    return ftir1_pct, ftir2_pct


# =============================================================================
# Main pipeline
# =============================================================================

def run_analysis(
    sites_path    = "path/to/Site.csv",
    animal_path   = "path/to/Animal.csv",
    sediment_path = "path/to/Sediment.csv",
    water_path    = "path/to/Water.csv",
    ftir1_path    = "path/to/FTIR_compound_summary.csv",
    ftir2_path    = "path/to/FTIR_shape_summary.csv",
):
    """
    Run the full analysis pipeline and return all results as a dict.

    Returns:
        dict with keys:
            datasets     — merged DataFrames (animal_site, bivalve_site, etc.)
            long         — long-format DataFrames for plotting
            averages     — site-level average DataFrames
            nonparametric — Kruskal-Wallis + Dunn results
            models       — best-fit GLM objects
            ftir1_pct    — FTIR compound percentage table
            ftir2_pct    — FTIR shape × type percentage table
    """
    # Load
    data = load_data(sites_path, animal_path, sediment_path, water_path,
                     ftir1_path, ftir2_path)

    # Build merged datasets
    datasets = build_merged_datasets(data)

    # Concentrations
    datasets = add_concentrations(datasets)

    # Site averages
    averages = {
        "animal_site_avg":   site_averages(datasets["animal_site"]),
        "bivalve_site_avg":  site_averages(datasets["bivalve_site"]),
        "sediment_site_avg": site_averages(datasets["sediment_site"]),
        "water_site_avg":    site_averages(datasets["water_site"]),
    }

    # Long format
    long = {
        "animal_long":      to_long(datasets["animal_site"]),
        "bivalve_long":     to_long(datasets["bivalve_site"]),
        "bivalve_sjh_long": to_long(datasets["bivalve_sjh_site"]),
        "sediment_long":    to_long(datasets["sediment_site"]),
        "water_long":       to_long(datasets["water_site"]),
    }

    # Nonparametric tests
    mp_all = CONC_COLS
    nonparametric = {
        "animal":      run_nonparametric(datasets["animal_site"],      mp_all, "waterbody",     "Animal (all) ~ waterbody"),
        "bivalve":     run_nonparametric(datasets["bivalve_site"],     mp_all, "waterbody",     "Bivalves (all) ~ waterbody"),
        "bivalve_sjh": run_nonparametric(datasets["bivalve_sjh_site"], mp_all, "species_common","Bivalves (SJH) ~ species"),
        "sediment":    run_nonparametric(datasets["sediment_site"],    mp_all, "waterbody",     "Sediment ~ waterbody"),
        "water":       run_nonparametric(datasets["water_site"],       mp_all, "waterbody",     "Water ~ waterbody"),
    }

    # GLMs
    models = run_all_glms(datasets)

    # FTIR
    ftir1_pct, ftir2_pct = build_ftir_summaries(data["ftir1"], data["ftir2"])

    print("\n\nAnalysis complete. Keys in returned dict:")
    print("  datasets, long, averages, nonparametric, models, ftir1_pct, ftir2_pct")

    return dict(
        datasets      = datasets,
        long          = long,
        averages      = averages,
        nonparametric = nonparametric,
        models        = models,
        ftir1_pct     = ftir1_pct,
        ftir2_pct     = ftir2_pct,
    )


if __name__ == "__main__":
    results = run_analysis()

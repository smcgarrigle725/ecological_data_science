# =============================================================================
# microparticles_analysis.R
# =============================================================================
# Statistical analysis of microparticle concentrations in animal, sediment,
# and water samples from the Wolastoq/Saint John River watershed.
#
# This script reproduces the analysis from:
#   McGarrigle et al. (in prep.) Integration and data sharing to examine the
#   fate and transport of microplastics in the Wolastoq/Saint John River watershed
#
# Workflow:
#   1.  Load packages
#   2.  Load data from CSV (or substitute CSVs exported from DynamoDB via
#       database/data_extraction.py → export_to_csv())
#   3.  Coerce column types
#   4.  Filter sites to SJ River watershed
#   5.  Merge sample tables with site metadata
#   6.  Subset animal table to bivalves; harbour-only subset
#   7.  Calculate normalized MP concentrations (per g tissue / dry wt / mL)
#   8.  Calculate site-level averages per year
#   9.  Reshape to long format for plotting
#   10. Nonparametric tests: Kruskal-Wallis + Conover post-hoc
#   11. GLMs: Gaussian, Poisson, Negative Binomial (AIC selection)
#   12. Tukey post-hoc comparisons via multcomp::glht
#   13. FTIR summary tables loaded and summarized separately
#
# All analysis objects are left in the environment for use by report_figures.R.
#
# Usage:
#   source("microparticles_analysis.R")   # loads all objects into environment
#   OR run interactively section by section
# =============================================================================


# =============================================================================
# 1. Packages
# =============================================================================

library(tidyverse)
library(dplyr)
library(openxlsx)

library(ggplot2)
library(ggpubr)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(ggspatial)
library(ggrepel)
library(ggthemes)
library(RColorBrewer)

library(nlme)
library(lme4)
library(tweedie)

library(multcomp)
library(PMCMRplus)
library(lmerTest)

library(DHARMa)
library(MuMIn)
library(AICcmodavg)

library(pscl)
library(car)
library(MASS)
library(glmmTMB)


# =============================================================================
# 2. Load data
# =============================================================================
# Replace paths with your local CSVs, or with files exported from DynamoDB
# using: database/data_extraction.py → export_to_csv("Site", "path/to/Site.csv")

sites    <- read.csv("path/to/Site.csv",     header = TRUE)
animal   <- read.csv("path/to/Animal.csv",   header = TRUE)
sediment <- read.csv("path/to/Sediment.csv", header = TRUE)
water    <- read.csv("path/to/Water.csv",    header = TRUE)

# FTIR summary tables (pre-aggregated counts from the FTIR DynamoDB table)
FTIR1 <- read.csv("path/to/FTIR_compound_summary.csv", header = TRUE)
FTIR2 <- read.csv("path/to/FTIR_shape_summary.csv",    header = TRUE)


# =============================================================================
# 3. Coerce column types
# =============================================================================

sites$year           <- as.factor(sites$year)
sites$waterbody      <- as.factor(sites$waterbody)
sites$waterbodytype  <- as.factor(sites$waterbodytype)
sites$site           <- as.factor(sites$site)
sites$siteid         <- as.factor(sites$siteid)
sites$benthicpelagic <- as.factor(sites$benthicpelagic)
sites$tidaldepth     <- as.factor(sites$tidaldepth)
sites$sampletypes    <- as.factor(sites$sampletypes)

animal$site            <- as.factor(animal$site)
animal$siteid          <- as.factor(animal$siteid)
animal$year            <- as.factor(animal$year)
animal$id              <- as.factor(animal$id)
animal$sampleid        <- as.factor(animal$sampleid)
animal$species_common  <- as.factor(animal$species_common)
animal$tissuetype      <- as.factor(animal$tissuetype)
animal$ftir_complete   <- as.factor(animal$ftir_complete)
animal$totalmp         <- as.numeric(animal$totalmp)
animal$fibre           <- as.numeric(animal$fibre)
animal$fragment        <- as.numeric(animal$fragment)
animal$sphere          <- as.numeric(animal$sphere)
animal$film            <- as.numeric(animal$film)
animal$ftir_numbersent <- as.numeric(animal$ftir_numbersent)

sediment$site            <- as.factor(sediment$site)
sediment$siteid          <- as.factor(sediment$siteid)
sediment$year            <- as.factor(sediment$year)
sediment$id              <- as.factor(sediment$id)
sediment$sampleid        <- as.factor(sediment$sampleid)
sediment$ftir_complete   <- as.factor(sediment$ftir_complete)
sediment$totalmp         <- as.numeric(sediment$totalmp)
sediment$fibre           <- as.numeric(sediment$fibre)
sediment$fragment        <- as.numeric(sediment$fragment)
sediment$sphere          <- as.numeric(sediment$sphere)
sediment$film            <- as.numeric(sediment$film)
sediment$ftir_numbersent <- as.numeric(sediment$ftir_numbersent)

water$site            <- as.factor(water$site)
water$siteid          <- as.factor(water$siteid)
water$year            <- as.factor(water$year)
water$id              <- as.factor(water$id)
water$sampleid        <- as.factor(water$sampleid)
water$ftir_complete   <- as.factor(water$ftir_complete)
water$totalmp         <- as.numeric(water$totalmp)
water$fibre           <- as.numeric(water$fibre)
water$fragment        <- as.numeric(water$fragment)
water$sphere          <- as.numeric(water$sphere)
water$film            <- as.numeric(water$film)
water$ftir_numbersent <- as.numeric(water$ftir_numbersent)

FTIR1$Matrix     <- as.factor(FTIR1$Matrix)
FTIR1$Compound   <- as.factor(FTIR1$Compound)
FTIR2$Matrix     <- as.factor(FTIR2$Matrix)
FTIR2$Shape      <- as.factor(FTIR2$Shape)
FTIR2$ParticleID <- as.factor(FTIR2$ParticleID)


# =============================================================================
# 4. Filter sites to SJ River watershed
# =============================================================================

WATERSHED_WATERBODIES <- c(
  "Saint John River", "Tobique River", "Nashwaak River",
  "Oromocto River", "Kennebecasis River", "Saint John Harbour"
)

sites_sj <- sites[sites$waterbody %in% WATERSHED_WATERBODIES, ]

# Split by sample type for targeted merges (avoids cross-matrix site contamination)
sites_sj_anim <- sites_sj[sites_sj$sampletypes == "Animal",   ]
sites_sj_sed  <- sites_sj[sites_sj$sampletypes == "Sediment", ]
sites_sj_wat  <- sites_sj[sites_sj$sampletypes == "Water",    ]


# =============================================================================
# 5. Merge sample tables with site metadata
# =============================================================================

# siteid must be character for clean merging
sites_sj_anim$siteid <- as.character(sites_sj_anim$siteid)
sites_sj_sed$siteid  <- as.character(sites_sj_sed$siteid)
sites_sj_wat$siteid  <- as.character(sites_sj_wat$siteid)

animal_site   <- merge(animal,   sites_sj_anim, by = "siteid")
sediment_site <- merge(sediment, sites_sj_sed,  by = "siteid")
water_site    <- merge(water,    sites_sj_wat,  by = "siteid")

# Trim to key columns from each sample table + selected site metadata.
# Drops partner-specific sub-columns (jk_*, ca_*, acap_*, prg_*, huntsman_*)
# that are not part of the standardized DynamoDB schema.
# intersect() ensures the selection is safe if a column is absent in any CSV.

ANIMAL_KEEP_COLS <- c(
  "siteid", "collection_organization.x", "primarycontact.x",
  "site.x", "year.x", "date", "id", "sampleid", "processingmethod",
  "species_common", "species_scientific", "number_animal",
  "sampleweight", "animallength", "tissuetype",
  "totalmp", "fibre", "fragment", "sphere", "film",
  "ftir_complete", "ftir_numbersent",
  "collection_organization.y", "primarycontact.y",
  "waterbody", "waterbodytype", "site.y",
  "latitude", "longitude", "substrate", "benthicpelagic"
)

BIVALVE_KEEP_COLS <- c(
  "siteid", "collection_organization.x",
  "site.x", "year.x", "date", "id", "sampleid", "processingmethod",
  "species_common", "species_scientific", "number_animal",
  "sampleweight", "animallength", "tissuetype",
  "totalmp", "fibre", "fragment", "sphere", "film",
  "ftir_complete", "ftir_numbersent",
  "collection_organization.y", "primarycontact.y",
  "waterbody", "waterbodytype", "site.y",
  "latitude", "longitude", "substrate", "benthicpelagic"
)

SEDIMENT_KEEP_COLS <- c(
  "siteid", "collection_organization.x", "primarycontact.x",
  "site.x", "year.x", "date", "id", "sampleid", "processingmethod",
  "sampleweight_wwt",
  "totalmp", "fibre", "fragment", "sphere", "film",
  "ftir_complete", "ftir_numbersent",
  "collection_organization.y", "primarycontact.y",
  "waterbody", "waterbodytype", "site.y",
  "latitude", "longitude", "substrate", "benthicpelagic",
  "tidaldepth", "samplestaken", "sampletypes"
)

WATER_KEEP_COLS <- c(
  "siteid", "collection_organization.x", "primarycontact.x",
  "site.x", "year.x", "date", "id", "sampleid", "processingmethod",
  "samplevolume",
  "totalmp", "fibre", "fragment", "sphere", "film",
  "ftir_complete", "ftir_numbersent",
  "collection_organization.y", "primarycontact.y",
  "waterbody", "waterbodytype", "site.y",
  "latitude", "longitude", "substrate", "benthicpelagic",
  "tidaldepth", "samplestaken", "sampletypes"
)

animal_site2  <- animal_site[,   intersect(ANIMAL_KEEP_COLS,   names(animal_site))]
sediment_site <- sediment_site[, intersect(SEDIMENT_KEEP_COLS, names(sediment_site))]
water_site    <- water_site[,    intersect(WATER_KEEP_COLS,    names(water_site))]


# =============================================================================
# 6. Subset animal table to bivalves; harbour-only subset
# =============================================================================

BIVALVE_SPECIES <- c(
  "Balthic clam", "Blue Mussel", "Eastern elliptio",
  "Eastern lampmussel", "Freshwater pearl mussel",
  "Macoma clam", "Ribbed Mussel", "Soft Shelled Clam", "Soft-shell clam"
)

bivalves <- animal[animal$species_common %in% BIVALVE_SPECIES, ]

bivalves$siteid      <- as.character(bivalves$siteid)
bivalve_site         <- merge(bivalves, sites_sj_anim, by = "siteid")
bivalve_site         <- bivalve_site[, intersect(BIVALVE_KEEP_COLS, names(bivalve_site))]

bivalve_sjh_site <- bivalve_site[bivalve_site$waterbody == "Saint John Harbour", ]


# =============================================================================
# 7. Normalized MP concentration columns
# =============================================================================
# Animal / bivalve: MPs per gram tissue     (count / sampleweight)
# Sediment:         MPs per gram dry weight  (count / sampleweight_wwt)
# Water:            MPs per mL              (count / samplevolume)

.add_concentration <- function(df, denominator) {
  for (col in c("totalmp", "fibre", "fragment", "sphere", "film")) {
    df[[paste0(col, "_g")]] <- df[[col]] / df[[denominator]]
  }
  df
}

animal_site2     <- .add_concentration(animal_site2,     "sampleweight")
bivalve_site     <- .add_concentration(bivalve_site,     "sampleweight")
bivalve_sjh_site <- .add_concentration(bivalve_sjh_site, "sampleweight")
sediment_site    <- .add_concentration(sediment_site,    "sampleweight_wwt")
water_site       <- .add_concentration(water_site,       "samplevolume")

# Re-add concentration to full animal_site for averaging (animal_site2 is trimmed)
animal_site      <- .add_concentration(animal_site,      "sampleweight")


# =============================================================================
# 8. Site-level averages per year
# =============================================================================

.site_averages <- function(df, year_col = "year.x") {
  averages <- df %>%
    group_by(siteid, !!sym(year_col)) %>%
    summarise(
      avg_totalmp_g  = mean(totalmp_g,  na.rm = TRUE),
      avg_fibre_g    = mean(fibre_g,    na.rm = TRUE),
      avg_fragment_g = mean(fragment_g, na.rm = TRUE),
      avg_sphere_g   = mean(sphere_g,   na.rm = TRUE),
      avg_film_g     = mean(film_g,     na.rm = TRUE),
      .groups = "drop"
    )
  distinct_rows <- distinct(df, siteid, .keep_all = TRUE)
  left_join(averages, distinct_rows, by = "siteid")
}

animal_site_avg   <- .site_averages(animal_site)
bivalve_site_avg  <- .site_averages(bivalve_site)
sediment_site_avg <- .site_averages(sediment_site)
water_site_avg    <- .site_averages(water_site)


# =============================================================================
# 9. Reshape to long format for plotting
# =============================================================================

CONC_COLS <- c("totalmp_g", "fibre_g", "fragment_g", "sphere_g", "film_g")

MP_LABELS <- c(
  fibre_g    = "Fibre",
  film_g     = "Film",
  fragment_g = "Fragment",
  sphere_g   = "Sphere",
  totalmp_g  = "Total"
)

WATERBODY_ORDER <- c(
  "Saint John River", "Tobique River", "Nashwaak River",
  "Oromocto River", "Kennebecasis River", "Saint John Harbour",
  "Annapolis Basin", "Atlantic Ocean", "Bay of Fundy", "Beaver Harbour",
  "Grand Harbour", "Gulf of St. Lawrence", "Lahave River", "Minas Basin",
  "Musquash Estuary", "Passamaquoddy Bay", "Saint Mary's Bay", "Whale Cove "
)

.to_long <- function(df) {
  long <- gather(df, key = "variable", value = "value", all_of(CONC_COLS))
  long$variable <- factor(long$variable,
                          levels = names(MP_LABELS),
                          labels = MP_LABELS)
  if ("waterbody" %in% names(long)) {
    long$waterbody <- factor(long$waterbody, levels = WATERBODY_ORDER)
  }
  long
}

animal_long      <- .to_long(animal_site)
bivalve_long     <- .to_long(bivalve_site)
bivalve_sjh_long <- .to_long(bivalve_sjh_site)
sediment_long    <- .to_long(sediment_site)
water_long       <- .to_long(water_site)


# =============================================================================
# 10. Nonparametric tests: Kruskal-Wallis + Conover post-hoc
# =============================================================================

.run_nonparametric <- function(df, response_vars, group_var, label) {
  cat("\n\n====", label, "====\n")
  for (rv in response_vars) {
    cat("\n--", rv, "--\n")
    formula_kw <- as.formula(paste(rv, "~ factor(", group_var, ")"))
    print(kruskal.test(formula_kw, data = df))
    formula_cn <- as.formula(paste(rv, "~", group_var))
    tryCatch(
      print(kwAllPairsConoverTest(formula_cn, data = df)),
      error = function(e) cat("  Conover test failed:", conditionMessage(e), "\n")
    )
  }
}

MP_TYPES <- c("totalmp_g", "fibre_g", "fragment_g", "sphere_g", "film_g")

.run_nonparametric(animal_site,      MP_TYPES, "waterbody",     "Animal (all) ~ waterbody")
.run_nonparametric(bivalve_site,     MP_TYPES, "waterbody",     "Bivalves (all) ~ waterbody")
.run_nonparametric(bivalve_sjh_site, MP_TYPES, "species_common","Bivalves (SJH) ~ species")
.run_nonparametric(sediment_site,    MP_TYPES, "waterbody",     "Sediment ~ waterbody")
.run_nonparametric(water_site,       MP_TYPES, "waterbody",     "Water ~ waterbody")


# =============================================================================
# 11. GLMs: family selection by AIC, then fit best model
# =============================================================================
# Pattern: fit Gaussian, Poisson, Negative Binomial; compare AIC.
# Negative Binomial consistently outperformed others in original analysis.
# sphere_g is excluded from GLMs: zero-inflated in most groups, NB theta
# estimation fails.

.fit_glms <- function(df, response, predictor) {
  formula    <- as.formula(paste(response, "~", predictor))
  glm_gauss  <- glm(formula, data = df, family = gaussian())
  glm_poiss  <- suppressWarnings(glm(formula, data = df, family = poisson()))
  glm_nb     <- tryCatch(
    glm.nb(formula, data = df),
    error = function(e) {
      cat("  NB failed for", response, ":", conditionMessage(e), "\n")
      NULL
    }
  )
  models <- list(gaussian = glm_gauss, poisson = glm_poiss)
  if (!is.null(glm_nb)) models$negbin <- glm_nb
  aic_table <- do.call(AIC, models)
  list(gaussian = glm_gauss, poisson = glm_poiss, negbin = glm_nb, aic = aic_table)
}

.summarize_best <- function(fit_list, response, predictor) {
  best <- if (!is.null(fit_list$negbin)) fit_list$negbin else fit_list$gaussian
  cat("\n--- Best model:", response, "~", predictor, "---\n")
  print(summary(best))
  print(car::Anova(best))
  tryCatch({
    tukey_spec <- setNames(list("Tukey"), predictor)
    tukey <- glht(best, linfct = mcp(tukey_spec[[1]]))
    print(summary(tukey))
  }, error = function(e) cat("  Tukey failed:", conditionMessage(e), "\n"))
  invisible(best)
}

# sphere_g excluded — NB theta estimation fails on near-zero distributions
MODEL_TYPES <- c("totalmp_g", "fibre_g", "fragment_g", "film_g")

cat("\n\n===== GLMs: Animal ~ waterbody =====\n")
animal_models <- setNames(lapply(MODEL_TYPES, function(rv) {
  fits <- .fit_glms(animal_site, rv, "waterbody")
  cat("\nAIC table —", rv, "\n"); print(fits$aic)
  .summarize_best(fits, rv, "waterbody")
}), MODEL_TYPES)

cat("\n\n===== GLMs: Bivalves ~ waterbody =====\n")
bivalve_models <- setNames(lapply(MODEL_TYPES, function(rv) {
  fits <- .fit_glms(bivalve_site, rv, "waterbody")
  cat("\nAIC table —", rv, "\n"); print(fits$aic)
  .summarize_best(fits, rv, "waterbody")
}), MODEL_TYPES)

cat("\n\n===== GLMs: SJH Bivalves ~ species_common =====\n")
bivalve_sjh_models <- setNames(lapply(MODEL_TYPES, function(rv) {
  fits <- .fit_glms(bivalve_sjh_site, rv, "species_common")
  cat("\nAIC table —", rv, "\n"); print(fits$aic)
  .summarize_best(fits, rv, "species_common")
}), MODEL_TYPES)

cat("\n\n===== GLMs: Sediment ~ waterbody =====\n")
sediment_models <- setNames(lapply(MODEL_TYPES, function(rv) {
  fits <- .fit_glms(sediment_site, rv, "waterbody")
  cat("\nAIC table —", rv, "\n"); print(fits$aic)
  .summarize_best(fits, rv, "waterbody")
}), MODEL_TYPES)

cat("\n\n===== GLMs: Water ~ waterbody =====\n")
water_models <- setNames(lapply(MODEL_TYPES, function(rv) {
  fits <- .fit_glms(water_site, rv, "waterbody")
  cat("\nAIC table —", rv, "\n"); print(fits$aic)
  .summarize_best(fits, rv, "waterbody")
}), MODEL_TYPES)


# =============================================================================
# 12. FTIR summaries
# =============================================================================

# Percent breakdown by compound per matrix (used by pie chart in report_figures.R)
FTIR1_pct <- FTIR1 %>%
  group_by(Matrix) %>%
  mutate(
    Percent = Count / sum(Count) * 100,
    Label   = ifelse(Percent > 3, paste0(round(Percent), "%"), "")
  )

# Recode ParticleID to plain-language labels; calculate shape × type percentages
FTIR2 <- FTIR2 %>%
  mutate(
    Type = dplyr::recode(ParticleID,
                         Plastic    = "Artificial",
                         Nonplastic = "Natural"),
    Type = factor(Type, levels = c("Natural", "Artificial"))
  )

FTIR2_pct <- FTIR2 %>%
  group_by(Matrix, Shape) %>%
  mutate(Percent = Count / sum(Count) * 100)


cat("\n\nAnalysis complete. Objects in environment:\n")
cat("  Sites:   sites_sj, sites_sj_anim, sites_sj_sed, sites_sj_wat\n")
cat("  Merged:  animal_site, bivalve_site, bivalve_sjh_site,\n")
cat("           sediment_site, water_site\n")
cat("  Long:    animal_long, bivalve_long, bivalve_sjh_long,\n")
cat("           sediment_long, water_long\n")
cat("  Avgs:    animal_site_avg, bivalve_site_avg,\n")
cat("           sediment_site_avg, water_site_avg\n")
cat("  Models:  animal_models, bivalve_models, bivalve_sjh_models,\n")
cat("           sediment_models, water_models\n")
cat("  FTIR:    FTIR1_pct, FTIR2_pct\n")

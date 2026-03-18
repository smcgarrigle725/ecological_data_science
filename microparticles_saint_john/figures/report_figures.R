# =============================================================================
# report_figures.R
# =============================================================================
# Generates all publication figures for the microparticles manuscript.
# Requires analysis objects produced by analysis/R/microparticles_analysis.R.
#
# Figures produced:
#   Fig. 1  — Map of sampling sites across the watershed
#   Fig. 2  — Boxplots: MPs per g tissue by waterbody (all animals)
#   Fig. 3  — Boxplots: MPs per g tissue by waterbody (bivalves only)
#   Fig. 4  — Boxplots: MPs per g tissue by species (SJH bivalves)
#   Fig. 5  — Boxplots: MPs per g dry weight by waterbody (sediment)
#   Fig. 6  — Boxplots: MPs per mL by waterbody (water)
#   Fig. 7  — Pie charts: FTIR polymer composition by matrix
#   Fig. 8  — Bar chart: MP shape × plastic confirmation by matrix
#
# All figures saved to: ../outputs/
#
# Usage:
#   source("../analysis/R/microparticles_analysis.R")  # load analysis objects
#   source("report_figures.R")                          # generate figures
# =============================================================================


# =============================================================================
# Setup
# =============================================================================

library(tidyverse)
library(ggplot2)
library(ggpubr)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(ggspatial)
library(RColorBrewer)

OUTPUT_DIR <- "../outputs"
dir.create(OUTPUT_DIR, showWarnings = FALSE)

# Shared plot settings
BASE_SIZE  <- 28       # base font size for publication figures
FIG_WIDTH  <- 16       # inches
FIG_HEIGHT <- 10       # inches
DPI        <- 300

# Color palettes
COLORS_DARK2 <- c("#1B9E77", "#D95F02", "#E7298A", "#66A61E", "#E6AB02")

# Waterbody x-axis order (SJ watershed first, then remaining)
WATERBODY_ORDER <- c(
  "Saint John River", "Tobique River", "Nashwaak River",
  "Oromocto River", "Kennebecasis River", "Saint John Harbour"
)

# Helper: save a ggplot to outputs/
.save_fig <- function(plot, filename, width = FIG_WIDTH, height = FIG_HEIGHT) {
  path <- file.path(OUTPUT_DIR, filename)
  ggsave(path, plot = plot, width = width, height = height, dpi = DPI)
  cat("Saved:", path, "\n")
}


# =============================================================================
# Fig. 1 — Site map
# =============================================================================

world <- ne_countries(scale = "medium", returnclass = "sf")

fig1 <- ggplot(data = world) +
  geom_sf() +
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotation_north_arrow(
    location = "bl", which_north = "true",
    pad_x = unit(0.25, "in"), pad_y = unit(0.25, "in"),
    style = north_arrow_fancy_orienteering
  ) +
  geom_point(
    data = sites_sj,
    aes(x = longitude, y = latitude, color = waterbody),
    size = 4
  ) +
  coord_sf(xlim = c(-69, -64), ylim = c(44, 48), expand = TRUE) +
  labs(x = "Longitude", y = "Latitude", color = "Waterbody") +
  scale_color_brewer(palette = "Dark2") +
  theme_bw(base_size = BASE_SIZE)

.save_fig(fig1, "fig1_site_map.png")


# =============================================================================
# Fig. 2 — Boxplot: All animals by waterbody
# =============================================================================

fig2 <- ggplot(
  drop_na(animal_long, waterbody),
  aes(x = variable, y = value, fill = waterbody)
) +
  geom_boxplot(outlier.size = 3) +
  xlab("Microparticle Classification") +
  ylab("Microparticles per g Tissue") +
  scale_fill_brewer(palette = "Dark2", name = "Waterbody") +
  scale_x_discrete(limits = c("Total", "Fibre", "Film", "Fragment", "Sphere")) +
  guides(fill = guide_legend(keywidth = 2, keyheight = 2)) +
  theme_classic(base_size = BASE_SIZE)

.save_fig(fig2, "fig2_animal_boxplot.png")


# =============================================================================
# Fig. 3 — Boxplot: Bivalves (all watershed) by waterbody
# =============================================================================

fig3 <- ggplot(
  drop_na(bivalve_long, waterbody),
  aes(x = variable, y = value, fill = waterbody)
) +
  geom_boxplot(outlier.size = 3) +
  xlab("Microparticle Classification") +
  ylab("Microparticles per g Tissue") +
  scale_fill_manual(values = COLORS_DARK2, name = "Waterbody") +
  scale_x_discrete(limits = c("Total", "Fibre", "Film", "Fragment", "Sphere")) +
  guides(fill = guide_legend(keywidth = 2, keyheight = 2)) +
  theme_classic(base_size = BASE_SIZE)

.save_fig(fig3, "fig3_bivalve_boxplot.png")


# =============================================================================
# Fig. 4 — Boxplot: SJH bivalves by species
# =============================================================================

fig4 <- ggplot(
  bivalve_sjh_long,
  aes(x = variable, y = value, fill = species_common)
) +
  geom_boxplot(outlier.size = 3) +
  xlab("Microparticle Classification") +
  ylab("Microparticles per g Tissue") +
  scale_fill_brewer(palette = "Dark2", name = "Species") +
  scale_x_discrete(limits = c("Total", "Fibre", "Film", "Fragment", "Sphere")) +
  guides(fill = guide_legend(keywidth = 2, keyheight = 2)) +
  theme_classic(base_size = BASE_SIZE)

.save_fig(fig4, "fig4_bivalve_sjh_species_boxplot.png")


# =============================================================================
# Fig. 5 — Boxplot: Sediment by waterbody
# =============================================================================

fig5 <- ggplot(
  drop_na(sediment_long, waterbody),
  aes(x = variable, y = value, fill = waterbody)
) +
  geom_boxplot(outlier.size = 3) +
  xlab("Microparticle Classification") +
  ylab("Microparticles per g Sediment") +
  scale_fill_brewer(palette = "Dark2", name = "Waterbody") +
  scale_x_discrete(limits = c("Total", "Fibre", "Film", "Fragment", "Sphere")) +
  guides(fill = guide_legend(keywidth = 2, keyheight = 2)) +
  theme_classic(base_size = BASE_SIZE)

.save_fig(fig5, "fig5_sediment_boxplot.png")


# =============================================================================
# Fig. 6 — Boxplot: Water by waterbody
# =============================================================================

fig6 <- ggplot(
  drop_na(water_long, waterbody),
  aes(x = variable, y = value, fill = waterbody)
) +
  geom_boxplot(outlier.size = 3) +
  xlab("Microparticle Classification") +
  ylab("Microparticles per mL Water") +
  scale_fill_brewer(palette = "Dark2", name = "Waterbody") +
  scale_x_discrete(limits = c("Total", "Fibre", "Film", "Fragment", "Sphere")) +
  guides(fill = guide_legend(keywidth = 2, keyheight = 2)) +
  theme_classic(base_size = BASE_SIZE)

.save_fig(fig6, "fig6_water_boxplot.png")


# =============================================================================
# Fig. 7 — Pie charts: FTIR polymer composition by matrix
# =============================================================================

fig7 <- ggplot(FTIR1_pct, aes(x = "", y = Percent, fill = Compound)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y") +
  facet_wrap(~Matrix) +
  geom_text(
    aes(label = Label),
    position = position_stack(vjust = 0.5),
    size = 5
  ) +
  scale_fill_brewer(palette = "Paired") +
  theme_classic(base_size = BASE_SIZE) +
  theme(
    axis.title   = element_blank(),
    axis.text    = element_blank(),
    axis.ticks   = element_blank(),
    panel.grid   = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 1),
    strip.background = element_rect(color = "black", fill = NA)
  )

.save_fig(fig7, "fig7_ftir_polymer_pie.png", height = 10)


# =============================================================================
# Fig. 8 — Bar chart: MP shape × plastic confirmation by matrix
# =============================================================================

fig8 <- ggplot(FTIR2_pct, aes(x = Shape, y = Percent, fill = Type)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~Matrix) +
  geom_text(
    aes(label = paste0(round(Percent), "%")),
    position = position_dodge(width = 0.8),
    vjust = -0.5,
    size = 4
  ) +
  scale_fill_brewer(palette = "Paired", name = "Material type") +
  labs(x = "MP Structure", y = "Percentage (%)") +
  theme_classic(base_size = BASE_SIZE) +
  theme(
    panel.border = element_rect(color = "black", fill = NA, linewidth = 1),
    strip.background = element_rect(color = "black", fill = NA)
  )

.save_fig(fig8, "fig8_ftir_shape_confirmation.png", height = 10)


cat("\nAll figures saved to:", OUTPUT_DIR, "\n")

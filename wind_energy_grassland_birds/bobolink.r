library(auk)
library(lubridate)
library(sf)
library(gridExtra)
library(tidyverse)
library(rnaturalearth)
library(dplyr)
#library(raster)
library(dggridR)
library(pdp)
library(mgcv)
library(zigam)
library(grplasso)
library(fitdistrplus)
library(MASS)
library(pscl)
library(AICcmodavg)
library(MuMIn)
library(DescTools)
library(viridis)
library(fields)
library(ggplot2)
library(ggpubr)
library(hglm)
library(corrplot)
#resolve namespace conflicts
select <- dplyr::select
map <- purrr::map
#projection <- raster::projection
gam <- mgcv::gam
# gam parameters
# degrees of freedom for smoothing
k <- 5
# degrees of freedom for cyclic time of day smooth
k_time <- 7 
# explicitly specify where the knots should occur for meanStartTime
# this ensures that the cyclic spline joins the variable at midnight
# this won't happen by default if there are no data near midnight
time_knots <- list(meanStartTime = seq(0, 24, length.out = k_time))
savspa_breed1_1.5 <- read_csv(file.choose()) #species_season_finaldata.csv
savspa_breed1b_1.5 <- savspa_breed1_1.5[,c(1:11, 18:45)] 
turbines <- read.csv(file.choose(), header=TRUE) #WRD_foranalysis.csv
summary(turbines)
start.time <-Sys.time()
savspa_breed_1.5 <- left_join(savspa_breed1b_1.5,turbines, by = 'cell_year')
savspa_breed_1.5 <- savspa_breed_1.5 %>% mutate(WindCount = ifelse(is.na(WindCount), 0, WindCount))
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(savspa_breed_1.5)
CRP <- read.csv(file.choose(), header=TRUE) #
CRP$year<-CRP$Year
summary(CRP)
savspa_breed_1.5 <- savspa_breed_1.5 %>%
  left_join(CRP %>% select(seqnum, year, CRP_area, CRPGrass_area), 
            by = c("seqnum" = "seqnum", "year" = "year"))
summary(savspa_breed_1.5)
#final prevalence
count(savspa_breed_1.5, species_observed) %>% mutate(percent = n / sum(n)) 

#get experimental group counts
savspa_breed_1.5 %>% count(CRP_area > 0 & WindCount > 0) %>% mutate(percent = n / sum(n)) #CRP & turbine
savspa_breed_1.5 %>% count(CRP_area > 0 & WindCount == 0) %>% mutate(percent = n / sum(n)) #CRP only
savspa_breed_1.5 %>% count(CRP_area == 0 & WindCount > 0) %>% mutate(percent = n / sum(n)) #turbine only
savspa_breed_1.5 %>% count(CRP_area == 0 & WindCount == 0) %>% mutate(percent = n / sum(n)) #neither CRP nor turbines
# Create Wind Presence/Absence Variable
savspa_breed_1.5$WindPA <- ifelse(savspa_breed_1.5$WindCount > 0, "Y", "N")
savspa_breed_1.5$WindPA<-as.factor(savspa_breed_1.5$WindPA)
# Convert Wind Age into a categorical variable with bins None, 0-1, 2-3, 4-5, 6-7, 8-9, 10+
savspa_breed_1.5$WindAge_cat <- ifelse(savspa_breed_1.5$WindPA == "N", "None",
                                   ifelse(savspa_breed_1.5$WindAge <= 2, "0-2",
                                          ifelse(savspa_breed_1.5$WindAge <= 4, "3-4",
                                                 ifelse(savspa_breed_1.5$WindAge <= 6, "5-6",
                                                        ifelse(savspa_breed_1.5$WindAge <= 8, "7-8", "9+")))))
savspa_breed_1.5$WindAge_cat <- as.factor(savspa_breed_1.5$WindAge_cat)
savspa_breed_1.5$WindAge_cat <- factor(savspa_breed_1.5$WindAge_cat, 
                                   levels = c("None", "0-2", "3-4", "5-6", "7-8", "9+"))
summary(savspa_breed_1.5$WindAge_cat)
# Convert Wind Height into a categorical variable with bins None, 1-20, 21-40, 41-60, 61-80, 81-100+
savspa_breed_1.5$WindHeight_cat <- ifelse(savspa_breed_1.5$WindPA == "N", "None",
                                       ifelse(savspa_breed_1.5$WindHeight > 0 & savspa_breed_1.5$WindHeight <= 20, "1-20",
                                              ifelse(savspa_breed_1.5$WindHeight > 20 & savspa_breed_1.5$WindHeight <= 40, "21-40",
                                                     ifelse(savspa_breed_1.5$WindHeight > 40 & savspa_breed_1.5$WindHeight <= 60, "41-60",
                                                            ifelse(savspa_breed_1.5$WindHeight > 60 & savspa_breed_1.5$WindHeight <= 80, "61-80",
                                                                   ifelse(savspa_breed_1.5$WindHeight > 80, "81-100+", NA))))))
savspa_breed_1.5$WindHeight_cat <- as.factor(savspa_breed_1.5$WindHeight_cat)
savspa_breed_1.5$WindHeight_cat <- factor(savspa_breed_1.5$WindHeight_cat, 
                                       levels = c("None", "1-20", "21-40", "41-60", "61-80", "81-100+"))
summary(savspa_breed_1.5$WindHeight_cat)
# Convert Wind RSA into a categorical variable with bins None, 1-20, 21-40, 41-60, 61-80, 81-100+
savspa_breed_1.5$WindRSA_cat <- ifelse(savspa_breed_1.5$WindPA == "N", "None",
                                   ifelse(savspa_breed_1.5$WindRSA > 0 & savspa_breed_1.5$WindRSA <= 5000, "0-5000",
                                          ifelse(savspa_breed_1.5$WindRSA > 5000 & savspa_breed_1.5$WindRSA <= 10000, "5001-10000",
                                                 ifelse(savspa_breed_1.5$WindRSA > 10000 & savspa_breed_1.5$WindRSA <= 15000, "10001-15000",
                                                        ifelse(savspa_breed_1.5$WindRSA > 15000, "15000+", NA)))))
savspa_breed_1.5$WindRSA_cat <- as.factor(savspa_breed_1.5$WindRSA_cat)
savspa_breed_1.5$WindRSA_cat <- factor(savspa_breed_1.5$WindRSA_cat, 
                                   levels = c("None", "0-5000", "5001-10000", "10001-15000", "15000+"))
summary(savspa_breed_1.5$WindRSA_cat)
# Convert Wind capacity into a categorical variable with bins None, 1-20, 21-40, 41-60, 61-80, 81-100+
savspa_breed_1.5$WindCap_cat <- ifelse(savspa_breed_1.5$WindPA == "N", "None",
                                   ifelse(savspa_breed_1.5$WindCap > 0 & savspa_breed_1.5$WindCap <= 1000, "0-1000",
                                          ifelse(savspa_breed_1.5$WindCap > 1000 & savspa_breed_1.5$WindCap <= 2000, "1001-2000",
                                                 ifelse(savspa_breed_1.5$WindCap > 2000 & savspa_breed_1.5$WindCap <= 3000, "2001-3000",
                                                        ifelse(savspa_breed_1.5$WindCap > 3000 & savspa_breed_1.5$WindCap <= 4000, "3001-4000",
                                                               ifelse(savspa_breed_1.5$WindCap > 4000, "4001+", NA))))))
savspa_breed_1.5$WindCap_cat <- as.factor(savspa_breed_1.5$WindCap_cat)
savspa_breed_1.5$WindCap_cat <- factor(savspa_breed_1.5$WindCap_cat, 
                                   levels = c("None", "0-1000", "1001-2000", "2001-3000", "3001-4000", "4001+"))
summary(savspa_breed_1.5$WindCap_cat)
summary(savspa_breed_1.5)
str(savspa_breed_1.5)
savspa_breed_1.5_NA <- savspa_breed_1.5 %>% drop_na(WindHeight_cat, WindCap_cat, WindRSA_cat)
str(savspa_breed_1.5_NA)

#final prevalence
count(savspa_breed_1.5_NA, species_observed) %>% mutate(percent = n / sum(n)) 

#get experimental group counts
savspa_breed_1.5_NA %>% count(CRP_area > 0 & WindCount > 0) %>% mutate(percent = n / sum(n)) #CRP & turbine
savspa_breed_1.5_NA %>% count(CRP_area > 0 & WindCount == 0) %>% mutate(percent = n / sum(n)) #CRP only
savspa_breed_1.5_NA %>% count(CRP_area == 0 & WindCount > 0) %>% mutate(percent = n / sum(n)) #turbine only
savspa_breed_1.5_NA %>% count(CRP_area == 0 & WindCount == 0) %>% mutate(percent = n / sum(n)) #neither CRP nor turbines
#use 0.5 to be conservative (Courtney's suggestion)
cortest <- savspa_breed_1.5_NA  %>% select(WindCount,
                             Developed, Cropland, GrassShrub, TreeCover, Water, Wetland, Barren, IceSnow,
                             meanStartTime, meanSampDur,meanDIST, meanNumObs,
                             CRP_area,CRP_largest_patch_index,CRP_patch_density,CRP_edge_density,CRP_contagion,
                             CRPGrass_area,CRPGrass_largest_patch_index,CRPGrass_patch_density,CRPGrass_edge_density,CRPGrass_contagion,
                             Hab_PercentGrassland,Hab_PercentWetland,
                             obj_PercentGrass,obj_PercentWetland,obj_PercentWildlife,
                             brd_PercentAttract,brd_PercentNeutral,brd_PercentAvoid)
savspa_breed_1.5_corr_matrix <- cor(cortest,use="complete.obs")
# Set the threshold for highlighting (e.g., r2 > 0.7)
threshold <- 0.4

# Reorder the columns of the correlation matrix
savspa_breed_1.5_corr_matrix <- savspa_breed_1.5_corr_matrix[, c("Developed", "Cropland", "GrassShrub", "TreeCover", "Water", "Wetland", 
                                                           "Barren", "IceSnow", "meanStartTime", "meanSampDur", 
                                                           "meanDIST", "meanNumObs", "WindCount", 
                                                           "CRP_area", "CRP_largest_patch_index", "CRP_patch_density", "CRP_edge_density", 
                                                           "CRP_contagion", "CRPGrass_area", "CRPGrass_largest_patch_index", 
                                                           "CRPGrass_patch_density", "CRPGrass_edge_density", "CRPGrass_contagion", 
                                                           "Hab_PercentGrassland", "Hab_PercentWetland", "obj_PercentGrass", 
                                                           "obj_PercentWetland", "obj_PercentWildlife", "brd_PercentAttract", 
                                                           "brd_PercentNeutral", "brd_PercentAvoid")]

write.csv(savspa_breed_1.5_corr_matrix, file = "savspa_breed_1.5_corr_matrix.csv", row.names = TRUE)
options(repr.plot.width=30, repr.plot.height=30)
corrplot(savspa_breed_1.5_corr_matrix, method = 'circle', col = COL2('PiYG', 10), 
         addCoef.col = 'black', insig = "pch", pch = c("", "."), 
         sig.level = 0.4)
#correlation issues: 
#* Cropland, TreeCover
#* Cropland, CRP Contagion
#* GrassShrub, CRP/Grass Area
#* GrassShrub, CRP/Grass Largest Patch Index
#remove grassshrub, cropland

#Effort Covariates
StartTime <- ggplot(savspa_breed_1.5_NA, aes(x = meanStartTime)) +
  geom_histogram(aes(y = ..density..), binwidth = 2, color = "black", fill = "white") +
  geom_density(alpha = 0.2, fill = "blue") +
  theme_bw()

SampDur <- ggplot(savspa_breed_1.5_NA, aes(x = meanSampDur)) +
  geom_histogram(aes(y = ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_density(alpha = 0.2, fill = "blue") +
  theme_bw()

DIST <- ggplot(savspa_breed_1.5_NA, aes(x = meanDIST)) +
  geom_histogram(aes(y = ..density..), binwidth = 1, color = "black", fill = "white") +
  geom_density(alpha = 0.2, fill = "blue") +
  theme_bw()

NumObs <- ggplot(savspa_breed_1.5_NA, aes(x = meanNumObs)) +
  geom_histogram(aes(y = ..density..), binwidth = 1, color = "black", fill = "white") +
  geom_density(alpha = 0.2, fill = "blue") +
  theme_bw()

ggarrange(StartTime, SampDur, DIST, NumObs, ncol = 2, nrow = 2, labels = c("A", "B", "C", "D"))
# LandCover Covariates

Developed <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(Developed, ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_density(aes(Developed), alpha = 0.2, fill = "blue") +
  theme_bw()

Cropland <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(Cropland, ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_density(aes(Cropland), alpha = 0.2, fill = "blue") +
  theme_bw()

GrassShrub <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(GrassShrub, ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_density(aes(GrassShrub), alpha = 0.2, fill = "blue") +
  theme_bw()

TreeCover <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(TreeCover, ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_density(aes(TreeCover), alpha = 0.2, fill = "blue") +
  theme_bw()

Water <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(Water, ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_density(aes(Water), alpha = 0.2, fill = "blue") +
  theme_bw()

Wetland <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(Wetland, ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_density(aes(Wetland), alpha = 0.2, fill = "blue") +
  theme_bw()

Barren <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(Barren, ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_density(aes(Barren), alpha = 0.2, fill = "blue") +
  theme_bw()

IceSnow <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(IceSnow, ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_density(aes(IceSnow), alpha = 0.2, fill = "blue") +
  theme_bw()

ggarrange(Developed, Cropland, GrassShrub, TreeCover, Water, Wetland, Barren, IceSnow, ncol = 4, nrow = 2, labels = c("A", "B", "C", "D", "E", "F", "G", "H"))
# Wind Covariates

WindCount <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(WindCount, ..density..), binwidth = 25, color = "black", fill = "white") +
  geom_histogram(aes(WindCount, ..density..), binwidth = 25, color = "black", fill = "blue", alpha = 0.2) +
  scale_x_continuous(breaks = seq(0, 350, by = 50)) +
  theme_bw()

WindHeight <- ggplot(savspa_breed_1.5_NA, aes(x=WindHeight_cat)) + 
  geom_bar()+
  theme_bw()

WindCap <- ggplot(savspa_breed_1.5_NA, aes(x=WindCap_cat)) + 
  geom_bar()+
  theme_bw()

WindAge <- ggplot(savspa_breed_1.5_NA, aes(x=WindAge_cat)) + 
  geom_bar()+
  theme_bw()

WindPA <- ggplot(savspa_breed_1.5_NA, aes(x=WindPA)) + 
  geom_bar()+
  theme_bw()

WindRSA <- ggplot(savspa_breed_1.5_NA, aes(x=WindRSA_cat)) + 
  geom_bar()+
  theme_bw()

ggarrange(WindCount, WindHeight, WindCap, WindAge, WindPA, WindRSA, ncol = 4, nrow = 2, labels = c("A", "B", "C", "D", "E", "F"))
options(repr.plot.width=50, repr.plot.height=40)
# CRP Covariates 
Hab_PercentGrassland <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(Hab_PercentGrassland, ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_histogram(aes(Hab_PercentGrassland, ..density..), binwidth = 10, color = "black", fill = "blue", alpha = 0.2) +
  scale_x_continuous(breaks = seq(0, 50, by = 10)) +
  theme_bw(base_size=40)

Hab_PercentWetland <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(Hab_PercentWetland, ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_histogram(aes(Hab_PercentWetland, ..density..), binwidth = 10, color = "black", fill = "blue", alpha = 0.2) +
  scale_x_continuous(breaks = seq(0, 30, by = 5)) +
  theme_bw(base_size=40)

obj_PercentGrass <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(obj_PercentGrass, ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_histogram(aes(obj_PercentGrass, ..density..), binwidth = 10, color = "black", fill = "blue", alpha = 0.2) +
  scale_x_continuous(breaks = seq(0, 40, by = 5)) +
  theme_bw(base_size=40)

obj_PercentWetland <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(obj_PercentWetland, ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_histogram(aes(obj_PercentWetland, ..density..), binwidth = 10, color = "black", fill = "blue", alpha = 0.2) +
  scale_x_continuous(breaks = seq(0, 25, by = 5)) +
  theme_bw(base_size=40)

obj_PercentWildlife <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(obj_PercentWildlife, ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_histogram(aes(obj_PercentWildlife, ..density..), binwidth = 10, color = "black", fill = "blue", alpha = 0.2) +
  scale_x_continuous(breaks = seq(0, 25, by = 5)) +
  theme_bw(base_size=40)

brd_PercentAttract <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(brd_PercentAttract, ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_histogram(aes(brd_PercentAttract, ..density..), binwidth = 10, color = "black", fill = "blue", alpha = 0.2) +
  scale_x_continuous(breaks = seq(0, 50, by = 10)) +
  theme_bw(base_size=40)

brd_PercentNeutral <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(brd_PercentNeutral, ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_histogram(aes(brd_PercentNeutral, ..density..), binwidth = 10, color = "black", fill = "blue", alpha = 0.2) +
  scale_x_continuous(breaks = seq(0, 25, by = 5)) +
  theme_bw(base_size=40)

brd_PercentAvoid <- ggplot(savspa_breed_1.5_NA) + 
  geom_density(aes(brd_PercentAvoid), bw = 0.5) + 
  scale_x_continuous(breaks = seq(0, 5, by = 1)) +
  theme_bw(base_size=40)
ggarrange(Hab_PercentGrassland, Hab_PercentWetland, 
          obj_PercentGrass, obj_PercentWetland, obj_PercentWildlife, 
          brd_PercentAttract, brd_PercentNeutral, brd_PercentAvoid, 
          ncol = 4, nrow = 2, labels = c("A", "B", "C", "D", "E", "F", "G", "H"))
CRP_area <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(CRP_area), binwidth = 250, color = "black", fill = "white") + 
  geom_histogram(aes(CRP_area), binwidth = 250, color = "black", fill = "blue", alpha = 0.2) + 
  scale_x_continuous(breaks = seq(0, 9700, by = 2500)) + 
  theme_bw(base_size=40)

CRP_largest_patch_index <- ggplot(savspa_breed_1.5_NA) + 
  geom_density(aes(CRP_largest_patch_index), bw = 0.05) + 
  scale_x_continuous(breaks = seq(0, 1, by = 0.1)) +
  theme_bw(base_size=40)

CRP_patch_density <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(CRP_patch_density, ..density..), binwidth = 0.1, color = "black", fill = "white") +
  geom_histogram(aes(CRP_patch_density, ..density..), binwidth = 0.1, color = "black", fill = "blue", alpha = 0.2) +
  scale_x_continuous(breaks = seq(0, 5, by = 1)) +
  theme_bw(base_size=40)

CRP_edge_density <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(CRP_edge_density, ..density..), binwidth = 0.1, color = "black", fill = "white") +
  geom_histogram(aes(CRP_edge_density, ..density..), binwidth = 0.1, color = "black", fill = "blue", alpha = 0.2) +
  scale_x_continuous(breaks = seq(0, 50, by = 10)) +
  theme_bw(base_size=40)

CRP_contagion <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(CRP_contagion, ..density..), binwidth = 0.1, color = "black", fill = "white") +
  geom_histogram(aes(CRP_contagion, ..density..), binwidth = 0.1, color = "black", fill = "blue", alpha = 0.2) +
  scale_x_continuous(breaks = seq(0, 1, by = 0.1)) +
  theme_bw(base_size=40)
CRPGrass_area <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(CRPGrass_area), binwidth = 250, color = "black", fill = "white") + 
  geom_histogram(aes(CRPGrass_area), binwidth = 250, color = "black", fill = "blue", alpha = 0.2) + 
  scale_x_continuous(breaks = seq(0, 9700, by = 2500)) + 
  theme_bw(base_size=40)

CRPGrass_largest_patch_index <- ggplot(savspa_breed_1.5_NA) + 
  geom_density(aes(CRPGrass_largest_patch_index), bw = 0.05) + 
  scale_x_continuous(breaks = seq(0, 1, by = 0.1)) +
  theme_bw(base_size=40)

CRPGrass_patch_density <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(CRPGrass_patch_density, ..density..), binwidth = 1, color = "black", fill = "white") +
  geom_histogram(aes(CRPGrass_patch_density, ..density..), binwidth = 1, color = "black", fill = "blue", alpha = 0.2) +
  scale_x_continuous(breaks = seq(0, 75, by = 5)) +
  theme_bw(base_size=40)

CRPGrass_edge_density <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(CRPGrass_edge_density, ..density..), binwidth = 10, color = "black", fill = "white") +
  geom_histogram(aes(CRPGrass_edge_density, ..density..), binwidth = 10, color = "black", fill = "blue", alpha = 0.2) +
  scale_x_continuous(breaks = seq(0, 175, by = 50)) +
  theme_bw(base_size=40)

CRPGrass_contagion <- ggplot(savspa_breed_1.5_NA) + 
  geom_histogram(aes(CRPGrass_contagion, ..density..), binwidth = 0.1, color = "black", fill = "white") +
  geom_histogram(aes(CRPGrass_contagion, ..density..), binwidth = 0.1, color = "black", fill = "blue", alpha = 0.2) +
  scale_x_continuous(breaks = seq(0, 1, by = 0.1)) +
  theme_bw(base_size=40)
ggarrange(CRP_area, CRP_largest_patch_index, CRP_patch_density, CRP_edge_density, CRP_contagion, 
          CRPGrass_area, CRPGrass_largest_patch_index, CRPGrass_patch_density, CRPGrass_edge_density, CRPGrass_contagion,
          ncol = 5, nrow = 2, labels = c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J"))
# Select the columns to scale
scaled_cols <- savspa_breed_1.5_NA %>% 
  select(meanStartTime, meanSampDur, meanDIST, meanNumObs, 
         Developed, Cropland, GrassShrub, TreeCover, Water, Wetland, Barren, IceSnow,
         WindCount, 
         Hab_PercentGrassland, Hab_PercentWetland,
         CRP_area, CRP_largest_patch_index, CRP_patch_density, CRP_edge_density, CRP_contagion,
         CRPGrass_area, CRPGrass_largest_patch_index, CRPGrass_patch_density, CRPGrass_edge_density, CRPGrass_contagion,
         obj_PercentGrass, obj_PercentWetland, obj_PercentWildlife, 
         brd_PercentAttract, brd_PercentNeutral, brd_PercentAvoid, 
         Lat, Long)

# Saving the means and sds for the scaled variables to use later on:
scaling_params <- scaled_cols %>% 
  summarise(across(where(is.numeric), list(mean = ~ mean(.), sd = ~ sd(.)))) %>% 
  pivot_longer(cols = everything(), values_to = "value", names_pattern = "(.*)_(.*)", names_to = c("variable", "statistic")) %>% 
  pivot_wider(names_from = "statistic", values_from = "value")
scaling_params

# Scale the selected columns
scaled_data <- scaled_cols %>% 
  mutate(across(where(is.numeric), scale))

# Combine the scaled data with the unscaled meanCount column
savspa_breed_scaled <- cbind(meanCount = savspa_breed_1.5_NA$meanCount, 
                             meanCount_round = savspa_breed_1.5_NA$meanCount_round, 
                             WindAge = savspa_breed_1.5_NA$WindAge_cat, 
                             WindHeight = savspa_breed_1.5_NA$WindHeight_cat, 
                             WindCap = savspa_breed_1.5_NA$WindCap_cat, 
                             WindRSA = savspa_breed_1.5_NA$WindRSA_cat,
                             WindPA = savspa_breed_1.5_NA$WindPA, 
                             scaled_data)
##need to split the dataset into test-train
savspa_breed_split <- savspa_breed_scaled %>% 
  # select only the columns to be used in the model
  select(meanCount, meanCount_round,
         # effort covariates
         meanStartTime, meanSampDur,meanDIST, meanNumObs,
        # landcover covariates
        Developed, Cropland, GrassShrub, TreeCover, Water, Wetland, Barren, IceSnow,
         # experimental covariates: wind
         WindCount,WindHeight,WindCap,WindAge,WindPA,WindRSA, 
        # experimental covariates: CRP
         Hab_PercentGrassland,Hab_PercentWetland,
         CRP_area,CRP_largest_patch_index,CRP_patch_density,CRP_edge_density,CRP_contagion,
         CRPGrass_area,CRPGrass_largest_patch_index,CRPGrass_patch_density,CRPGrass_edge_density,CRPGrass_contagion,
         obj_PercentGrass, obj_PercentWetland, obj_PercentWildlife, 
         brd_PercentAttract, brd_PercentNeutral, brd_PercentAvoid, 
        # lat/long
        Lat, Long)
#split 80/20
savspa_breed_split <- savspa_breed_split %>% 
  split(if_else(runif(nrow(.)) <= 0.8, "train", "test"))
map_int(savspa_breed_split, nrow)
options(repr.plot.width=20, repr.plot.height=20)
p <- par(mfrow = c(1, 2))

#counts with zeros
hist(savspa_breed_1.5_NA$meanCount, main = "Histogram of counts", 
     xlab = "Observed count")

#counts without zeros
pos_counts <- keep(savspa_breed_1.5_NA$meanCount, ~ . > 0)
hist(pos_counts, main = "Histogram of counts > 0", 
     xlab = "Observed non-zero count")
par(p)
options(repr.plot.width=20, repr.plot.height=20)
# assume 'data' is your dataset and 'x' is the variable you want to count

num_zeros <- sum(savspa_breed_1.5_NA$meanCount_round == 0)
num_non_zeros <- sum(savspa_breed_1.5_NA$meanCount_round != 0)

cat("Number of zeros:", num_zeros, "\n")
cat("Number of non-zeros:", num_non_zeros, "\n")
ggplot(savspa_breed_1.5_NA, aes(x = meanCount_round)) + 
  geom_histogram(
    binwidth = 10, 
    boundary = 0, 
    origin = -0.5, 
    color = "black"
  ) + 
  theme_classic(base_size=50) + 
  labs(x = "Abundance", y = "Frequency")

# GAMs allow non-linear fits for the covariates. You can allow different covariates to have a different amount of "wiggliness". Here, eBird recommends k=5 for most and k=7 plus a cubic cylic spline for time of day (because it's cyclical)
# gam parameters
# degrees of freedom for smoothing
k <- 5
# degrees of freedom for cyclic time of day smooth
k_time <- 7 
# explicitly specify where the knots should occur for meanStartTime
# this ensures that the cyclic spline joins the variable at midnight
# this won't happen by default if there are no data near midnight
time_knots <- list(meanStartTime = seq(0, 24, length.out = k_time))
Null <- meanCount_round ~ 1
start.time <-Sys.time()
gamtest_null_nb <- gam(Null, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
start.time <-Sys.time()
gamtest_null_p <- gam(Null, data = savspa_breed_split$train, family = "poisson", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
start.time <-Sys.time()
gamtest_null_zinb <- zinbgam(Null,  pi.formula = ~ 1, data = savspa_breed_split$train, knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
start.time <-Sys.time()
gamtest_null_zip <- gam(Null, data = savspa_breed_split$train, family = "ziP", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
gamtest_null_qp <- gam(Null,
                 data = savspa_breed_split$train,
                 family = "quasipoisson",
                 knots = time_knots)
gam_models <- list(gamtest_null_nb, gamtest_null_zinb, gamtest_null_p, gamtest_null_zip)
AIC(gamtest_null_nb, gamtest_null_p, gamtest_null_zip)
BIC(gamtest_null_nb, gamtest_null_p, gamtest_null_zip)
AIC_zinb <- gamtest_null_zinb$aic
AIC_zinb
BIC_zinb <- AIC_zinb + log(nrow(savspa_breed_split$train)) * (length(coef(gamtest_null_zinb)) - length(fitted(gamtest_null_zinb)) + 1)
BIC_zinb
# Here is the summary printout for the quasi-Poisson GAM
sum.gam <- summary(gamtest_null_qp)
sum.gam

# Print the vector of parametric coefficient p-values, rounded using round2() to three decimal places
sum.gam$p.pv

# Print the vector of smooth terms' p-values, rounded using round2() to three decimal places.
sum.gam$s.pv

# Extract the residuals (in units of the response)
resid<-residuals(gamtest_null_qp, type = "response")
sum(resid)
#** Best performing family distribution is Negative Binomial **
null <-meanCount ~ s(Lat, k = 5) + s(Long, k = 5)
effort_SampDur <-meanCount ~ s(meanSampDur, k = 5) + s(Lat, k = 5) + s(Long, k = 5)
effort_NumObs <-meanCount ~ s(meanNumObs, k = 5)+ s(Lat, k = 5) + s(Long, k = 5)
effort_Dist <-meanCount ~ s(meanDIST, k = 5)+ s(Lat, k = 5) + s(Long, k = 5)
effort_StartTime <-meanCount ~ s(meanStartTime, bs = "cc", k = 7)+ s(Lat, k = 5) + s(Long, k = 5)
effort_Global <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+ s(Lat, k = 5) + s(Long, k = 5)
start.time <-Sys.time()
m_effort_null <-gam(null, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_effort_null)
start.time <-Sys.time()
m_effort_SampDur <-gam(effort_SampDur, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_effort_SampDur)
start.time <-Sys.time()
m_effort_NumObs <-gam(effort_NumObs, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_effort_NumObs)
start.time <-Sys.time()
m_effort_Dist <-gam(effort_Dist, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_effort_Dist)
start.time <-Sys.time()
m_effort_StartTime <-gam(effort_StartTime, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_effort_StartTime)
start.time <-Sys.time()
m_effort_global <-gam(effort_Global, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_effort_global)
MuMIn::AICc(m_effort_null, m_effort_SampDur, m_effort_NumObs, m_effort_Dist, m_effort_StartTime, m_effort_global)
lc_developed <-meanCount ~ s(Developed, k = 5)+ s(Lat, k = 5) + s(Long, k = 5)
lc_cropland <-meanCount ~ s(Cropland, k = 5)+ s(Lat, k = 5) + s(Long, k = 5)
lc_grasshrub <-meanCount ~ s(GrassShrub, k = 5)+ s(Lat, k = 5) + s(Long, k = 5)
lc_treecover <-meanCount ~ s(TreeCover, k = 5)+ s(Lat, k = 5) + s(Long, k = 5)
lc_water <-meanCount ~ s(Water, k = 5)+ s(Lat, k = 5) + s(Long, k = 5)
lc_wetland <-meanCount ~ s(Wetland, k = 5)+ s(Lat, k = 5) + s(Long, k = 5)
lc_barren <-meanCount ~ s(Barren, k = 5)+ s(Lat, k = 5) + s(Long, k = 5)
lc_icesnow <-meanCount ~ s(IceSnow, k = 5)+ s(Lat, k = 5) + s(Long, k = 5)
lc_null <-meanCount ~ s(Lat, k = 5) + s(Long, k = 5)
start.time <-Sys.time()
m_lc_null <-gam(lc_null, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_lc_null)
start.time <-Sys.time()
m_lc_developed <-gam(lc_developed, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_lc_developed)
start.time <-Sys.time()
m_lc_cropland <-gam(lc_cropland, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_lc_cropland)
start.time <-Sys.time()
m_lc_grasshrub <-gam(lc_grasshrub, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_lc_grasshrub)
start.time <-Sys.time()
m_lc_treecover <-gam(lc_treecover, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_lc_treecover)
start.time <-Sys.time()
m_lc_water <-gam(lc_water, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_lc_water)
start.time <-Sys.time()
m_lc_wetland <-gam(lc_wetland, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_lc_wetland)
start.time <-Sys.time()
m_lc_barren <-gam(lc_barren, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_lc_barren)
start.time <-Sys.time()
m_lc_icesnow <-gam(lc_icesnow, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_lc_icesnow)
MuMIn::AICc(m_lc_null, m_lc_developed, m_lc_cropland, m_lc_grasshrub, m_lc_treecover, m_lc_water, m_lc_wetland, m_lc_barren, m_lc_icesnow)
Wind_windcount_simple <- meanCount ~ s(WindCount, k = 5)+ s(Lat, k = 5) + s(Long, k = 5)
Wind_windPA_simple <- meanCount ~ factor(WindPA)+ s(Lat, k = 5) + s(Long, k = 5)
Wind_windrsa_simple <- meanCount ~ factor(WindRSA)+ s(Lat, k = 5) + s(Long, k = 5)
Wind_windheight_simple <- meanCount ~ factor(WindHeight)+ s(Lat, k = 5) + s(Long, k = 5)
Wind_windage_simple <- meanCount ~ factor(WindAge)+ s(Lat, k = 5) + s(Long, k = 5)
Wind_windcap_simple <- meanCount ~ factor(WindCap)+ s(Lat, k = 5) + s(Long, k = 5)
start.time <-Sys.time()
m_wind_count_simple <-gam(Wind_windcount_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_wind_count_simple)
start.time <-Sys.time()
m_wind_cap_simple <-gam(Wind_windcap_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_wind_cap_simple)
start.time <-Sys.time()
m_Wind_windPA_simple <-gam(Wind_windPA_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_Wind_windPA_simple)
start.time <-Sys.time()
m_wind_rsa_simple <-gam(Wind_windrsa_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_wind_rsa_simple)
start.time <-Sys.time()
m_wind_height_simple <-gam(Wind_windheight_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_wind_height_simple)
start.time <-Sys.time()
m_wind_age_simple <-gam(Wind_windage_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_wind_age_simple)
MuMIn::AICc(m_wind_count_simple, m_wind_cap_simple, m_Wind_windPA_simple, m_wind_rsa_simple, m_wind_height_simple, m_wind_age_simple, m_lc_null)
Wind_windcount <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        WindCount
Wind_windcap <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        factor(WindCap)
Wind_windPA <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) + 
                        factor(WindPA)
Wind_windrsa <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) + 
                        factor(WindRSA)
Wind_windheight <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) + 
                        factor(WindHeight)
Wind_windage <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) + 
                        factor(WindAge)
Wind_null <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5)  
start.time <-Sys.time()
m_wind_count <-gam(Wind_windcount, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_wind_count)
start.time <-Sys.time()
m_wind_cap <-gam(Wind_windcap, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_wind_cap)
start.time <-Sys.time()
m_Wind_windPA <-gam(Wind_windPA, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_Wind_windPA)
start.time <-Sys.time()
m_wind_rsa <-gam(Wind_windrsa, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_wind_rsa)
start.time <-Sys.time()
m_wind_height <-gam(Wind_windheight, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_wind_height)
start.time <-Sys.time()
m_wind_age <-gam(Wind_windage, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_wind_age)
start.time <-Sys.time()
m_wind_null <-gam(Wind_null, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_wind_null)
MuMIn::AICc(m_wind_count, m_wind_cap, m_Wind_windPA, m_wind_rsa, m_wind_height, m_wind_age, m_wind_null)
CRP_Hab_PercentGrassland_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(Hab_PercentGrassland, k = 5) 
CRP_Hab_PercentWetland_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(Hab_PercentWetland, k = 5)
CRP_CRP_area_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(CRP_area, k = 5)
CRP_CRP_largest_patch_index_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(CRP_largest_patch_index, k = 5)
CRP_CRP_patch_density_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(CRP_patch_density, k = 5)
CRP_CRP_edge_density_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(CRP_edge_density, k = 5)
CRP_CRP_contagion_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(CRP_contagion, k = 5)
CRP_CRPGrass_area_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(CRPGrass_area, k = 5)
CRP_CRPGrass_largest_patch_index_simple <-  meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(CRPGrass_largest_patch_index, k = 5)
CRP_CRPGrass_patch_density_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(CRPGrass_patch_density, k = 5)
CRP_CRPGrass_edge_density_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(CRPGrass_edge_density, k = 5)
CRP_CRPGrass_contagion_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(CRPGrass_contagion, k = 5)
CRP_obj_PercentGrass_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(obj_PercentGrass, k = 5)
CRP_obj_PercentWetland_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(obj_PercentWetland, k = 5)
CRP_obj_PercentWildlife_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(obj_PercentWildlife, k = 5)
CRP_brd_PercentAttract_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(brd_PercentAttract, k = 5)
CRP_brd_PercentNeutral_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(brd_PercentNeutral, k = 5)
CRP_brd_PercentAvoid_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) + s(brd_PercentAvoid, k = 5)
CRP_null_simple <- meanCount ~ s(Lat, k = 5) + s(Long, k = 5) 
start.time <-Sys.time()
m_CRP_Hab_PercentGrassland_simple <-gam(CRP_Hab_PercentGrassland_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_Hab_PercentGrassland_simple)
start.time <-Sys.time()
m_CRP_Hab_PercentWetland_simple <-gam(CRP_Hab_PercentWetland_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_Hab_PercentWetland_simple)
start.time <-Sys.time()
m_CRP_CRP_area_simple <-gam(CRP_CRP_area_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRP_area_simple)
start.time <-Sys.time()
m_CRP_CRP_largest_patch_index_simple <-gam(CRP_CRP_largest_patch_index_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRP_largest_patch_index_simple)
start.time <-Sys.time()
m_CRP_CRP_patch_density_simple <-gam(CRP_CRP_patch_density_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRP_patch_density_simple)
start.time <-Sys.time()
m_CRP_CRP_edge_density_simple <-gam(CRP_CRP_edge_density_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRP_edge_density_simple)
start.time <-Sys.time()
m_CRP_CRP_contagion_simple <-gam(CRP_CRP_contagion_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRP_contagion_simple)
start.time <-Sys.time()
m_CRP_CRPGrass_area_simple <-gam(CRP_CRPGrass_area_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRPGrass_area_simple)
start.time <-Sys.time()
m_CRP_CRPGrass_largest_patch_index_simple <-gam(CRP_CRPGrass_largest_patch_index_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRPGrass_largest_patch_index_simple)
start.time <-Sys.time()
m_CRP_CRPGrass_patch_density_simple <-gam(CRP_CRPGrass_patch_density_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRPGrass_patch_density_simple)
start.time <-Sys.time()
m_CRP_CRPGrass_edge_density_simple <-gam(CRP_CRPGrass_edge_density_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRPGrass_edge_density_simple)
start.time <-Sys.time()
m_CRP_CRPGrass_contagion_simple <-gam(CRP_CRPGrass_contagion_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRPGrass_contagion_simple)
start.time <-Sys.time()
m_CRP_obj_PercentGrass_simple <-gam(CRP_obj_PercentGrass_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_obj_PercentGrass_simple)
start.time <-Sys.time()
m_CRP_obj_PercentWetland_simple <-gam(CRP_obj_PercentWetland_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_obj_PercentWetland_simple)
start.time <-Sys.time()
m_CRP_obj_PercentWildlife_simple <-gam(CRP_obj_PercentWildlife_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_obj_PercentWildlife_simple)
start.time <-Sys.time()
m_CRP_brd_PercentAttract_simple <-gam(CRP_brd_PercentAttract_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_brd_PercentAttract_simple)
start.time <-Sys.time()
m_CRP_brd_PercentNeutral_simple <-gam(CRP_brd_PercentNeutral_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_brd_PercentNeutral_simple)
start.time <-Sys.time()
m_CRP_brd_PercentAvoid_simple <-gam(CRP_brd_PercentAvoid_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_brd_PercentAvoid_simple)
start.time <-Sys.time()
m_CRP_null_simple <-gam(CRP_null_simple, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_null_simple)
MuMIn::AICc(m_CRP_Hab_PercentGrassland_simple, m_CRP_Hab_PercentWetland_simple, 
     m_CRP_CRP_area_simple, m_CRP_CRP_largest_patch_index_simple, m_CRP_CRP_patch_density_simple, m_CRP_CRP_edge_density_simple, m_CRP_CRP_contagion_simple, 
     m_CRP_CRPGrass_area_simple, m_CRP_CRPGrass_largest_patch_index_simple, m_CRP_CRPGrass_patch_density_simple, m_CRP_CRPGrass_edge_density_simple, m_CRP_CRPGrass_contagion_simple, 
     m_CRP_obj_PercentGrass_simple, m_CRP_obj_PercentWetland_simple, m_CRP_obj_PercentWildlife_simple, 
     m_CRP_brd_PercentAttract_simple, m_CRP_brd_PercentNeutral_simple, m_CRP_brd_PercentAvoid_simple, m_CRP_null_simple)
CRP_Hab_PercentGrassland <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        s(Hab_PercentGrassland, k = 5)
CRP_Hab_PercentWetland <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        Hab_PercentWetland
CRP_CRP_area <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        s(CRP_area, k = 5)
CRP_CRP_largest_patch_index <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        s(CRP_largest_patch_index, k = 5)
CRP_CRP_patch_density <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        s(CRP_patch_density, k = 5)
CRP_CRP_edge_density <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        s(CRP_edge_density, k = 5)
CRP_CRP_contagion <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        s(CRP_contagion, k = 5)
CRP_CRPGrass_area <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        s(CRPGrass_area, k = 5)
CRP_CRPGrass_largest_patch_index <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        s(CRPGrass_largest_patch_index, k = 5)
CRP_CRPGrass_patch_density <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        s(CRPGrass_patch_density, k = 5)
CRP_CRPGrass_edge_density <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        s(CRPGrass_edge_density, k = 5)
CRP_CRPGrass_contagion <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        s(CRPGrass_contagion, k = 5)
CRP_obj_PercentGrass <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        s(obj_PercentGrass, k = 5)
CRP_obj_PercentWetland <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        obj_PercentWetland
CRP_obj_PercentWildlife <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        obj_PercentWildlife
CRP_brd_PercentAttract <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        s(brd_PercentAttract, k = 5)
CRP_brd_PercentNeutral <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        brd_PercentNeutral
CRP_brd_PercentAvoid <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        s(brd_PercentAvoid, k = 5)
CRP_null <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5)
start.time <-Sys.time()
m_CRP_Hab_PercentGrassland <-gam(CRP_Hab_PercentGrassland, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_Hab_PercentGrassland)
start.time <-Sys.time()
m_CRP_Hab_PercentWetland <-gam(CRP_Hab_PercentWetland, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_Hab_PercentWetland)
start.time <-Sys.time()
m_CRP_CRP_area <-gam(CRP_CRP_area, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRP_area)
start.time <-Sys.time()
m_CRP_CRP_largest_patch_index <-gam(CRP_CRP_largest_patch_index, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRP_largest_patch_index)
start.time <-Sys.time()
m_CRP_CRP_patch_density <-gam(CRP_CRP_patch_density, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRP_patch_density)
start.time <-Sys.time()
m_CRP_CRP_edge_density <-gam(CRP_CRP_edge_density, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRP_edge_density)
start.time <-Sys.time()
m_CRP_CRP_contagion <-gam(CRP_CRP_contagion, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRP_contagion)
start.time <-Sys.time()
m_CRP_CRPGrass_area <-gam(CRP_CRPGrass_area, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRPGrass_area)
start.time <-Sys.time()
m_CRP_CRPGrass_largest_patch_index <-gam(CRP_CRPGrass_largest_patch_index, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRPGrass_largest_patch_index)
start.time <-Sys.time()
m_CRP_CRPGrass_patch_density <-gam(CRP_CRPGrass_patch_density, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRPGrass_patch_density)
start.time <-Sys.time()
m_CRP_CRPGrass_edge_density <-gam(CRP_CRPGrass_edge_density, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRPGrass_edge_density)
start.time <-Sys.time()
m_CRP_CRPGrass_contagion <-gam(CRP_CRPGrass_contagion, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_CRPGrass_contagion)
start.time <-Sys.time()
m_CRP_obj_PercentGrass <-gam(CRP_obj_PercentGrass, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken 
summary(m_CRP_obj_PercentGrass)
start.time <-Sys.time()
m_CRP_obj_PercentWetland <-gam(CRP_obj_PercentWetland, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_obj_PercentWetland)
start.time <-Sys.time()
m_CRP_obj_PercentWildlife <-gam(CRP_obj_PercentWildlife, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_obj_PercentWildlife)
start.time <-Sys.time()
m_CRP_brd_PercentAttract <-gam(CRP_brd_PercentAttract, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_brd_PercentAttract)
start.time <-Sys.time()
m_CRP_brd_PercentNeutral <-gam(CRP_brd_PercentNeutral, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_brd_PercentNeutral)
start.time <-Sys.time()
m_CRP_brd_PercentAvoid <-gam(CRP_brd_PercentAvoid, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_brd_PercentAvoid)
start.time <-Sys.time()
m_CRP_null <-gam(CRP_null, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_CRP_null)
MuMIn::AICc(m_CRP_Hab_PercentGrassland, m_CRP_Hab_PercentWetland, 
     m_CRP_CRP_area, m_CRP_CRP_largest_patch_index, m_CRP_CRP_patch_density, m_CRP_CRP_edge_density, m_CRP_CRP_contagion, 
     m_CRP_CRPGrass_area, m_CRP_CRPGrass_largest_patch_index, m_CRP_CRPGrass_patch_density, m_CRP_CRPGrass_edge_density, m_CRP_CRPGrass_contagion, 
     m_CRP_obj_PercentGrass, m_CRP_obj_PercentWetland, m_CRP_obj_PercentWildlife, 
     m_CRP_brd_PercentAttract, m_CRP_brd_PercentNeutral, m_CRP_brd_PercentAvoid, m_CRP_null)
Wind_Height <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) + 
                        factor(WindHeight)
CRP_CGArea <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) +
                        s(CRPGrass_area, k = 5)
Height_CGArea_inter <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) + 
                        factor(WindHeight) + s(CRPGrass_area, k = 5) + factor(WindHeight):CRPGrass_area
Height_CGArea_add <- meanCount ~ s(meanSampDur, k = 5) + s(meanNumObs, k = 5) + s(meanDIST, k = 5) + s(meanStartTime, bs = "cc", k = 7)+
                        s(Developed, k = 5) + s(TreeCover, k = 5) + s(Water, k = 5) + s(Wetland, k = 5) + s(Barren, k = 5)+ s(IceSnow, k = 5) + s(Lat, k = 5) + s(Long, k = 5) + 
                        factor(WindHeight) + s(CRPGrass_area, k = 5) 
m_Wind_Height <-gam(Wind_Height, data = savspa_breed_split$train, family = "nb", knots = time_knots)
m_CRP_CGArea <-gam(CRP_CGArea, data = savspa_breed_split$train, family = "nb", knots = time_knots)
summary(m_Wind_Height)
summary(m_CRP_CGArea)
start.time <-Sys.time()
m_Height_CGArea_inter <-gam(Height_CGArea_inter, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_Height_CGArea_inter)
start.time <-Sys.time()
m_Height_CGArea_add <-gam(Height_CGArea_add, data = savspa_breed_split$train, family = "nb", knots = time_knots)
end.time <- Sys.time()
time.taken <- round(end.time-start.time, 2)
time.taken
summary(m_Height_CGArea_add)
AICc(m_Wind_Height, m_CRP_CGArea, m_Height_CGArea_inter, m_Height_CGArea_add)
gam.vcomp(m_Wind_Height, rescale = TRUE)
gam.vcomp(m_CRP_CGArea, rescale = TRUE)
gam.vcomp(m_Height_CGArea_inter, rescale = TRUE)
gam.vcomp(m_Height_CGArea_add, rescale = TRUE)
anova(m_Wind_Height)
anova(m_CRP_CGArea)
anova(m_Height_CGArea_inter)
anova(m_Height_CGArea_add)
plot(m_Height_CGArea_add)
# Extract scaling parameters for CRPGrass_contagion and WindCap
scaling_params_sub <- scaling_params %>%
  filter(variable %in% c("CRPGrass_area"))
# Generate predictions
predictions <- predict.gam(m_Height_CGArea_inter, newdata = savspa_breed_split$test, type = "response", se.fit=TRUE)

# Add the predictions to the new data frame
pred_df <- data.frame(savspa_breed_split$test, predicted = predictions$fit)

# Unstandardize WindCap and CRPGrass_contagion
pred_df$CRPGrass_area_unstandardized <- pred_df$CRPGrass_area * scaling_params_sub$sd[scaling_params_sub$variable == "CRPGrass_area"] + scaling_params_sub$mean[scaling_params_sub$variable == "CRPGrass_area"]

# Create a ggplot plot (additive)
ggplot(pred_df, aes(x = CRPGrass_area_unstandardized, y = predicted, color = WindHeight)) + 
  geom_smooth() + 
  labs(x = "CRP/Grass Area (unstandardized)", y = "Predicted Abundance", color = "Wind Turbine Height")

rm(list = ls())
library(data.table)
library(tidyverse)
# ---------------------------------------------
# Load config
source("Rscripts/config.R")

# ------------------------------------------------------------------------
#### Load temp file
meta_qc_samples_df <- fread(paste(TEMP_DIR, "04_meta_qc_samples_df.txt", sep = "/"))
meta_qc_samples_df <- data.frame(meta_qc_samples_df)

# Getting subsample relevant metadata for covar file
covar_df <- meta_qc_samples_df %>%
  summarize(FID = eid, IID = eid, sex = sex, yob = yob, assessCenter = assessCenter,  bmi = bmi, genotyping.array = genotyping.array)

# Loading new subsample specific PCs
unrelated_pc_df <- read_delim(paste(DATA_DIR, "pcs.txt", sep ="/"), delim="\t")
related_pc_df <- read_delim(paste(DATA_DIR, "projections.txt", sep = "/"), delim="\t")

# Converting joining column IID and FID values to character
covar_df <- covar_df %>%
  mutate(FID = as.character(FID)) %>%
  mutate(IID = as.character(IID))

unrelated_pc_df <- unrelated_pc_df %>%
  mutate(FID = as.character(FID)) %>%
  mutate(IID = as.character(IID))

related_pc_df <- related_pc_df %>%
  mutate(FID = as.character(FID)) %>%
  mutate(IID = as.character(IID))

# Inner joining PCs for unrelated and related 
unrelated_covar_df <- covar_df %>%
  inner_join(unrelated_pc_df, by= c("FID" = "FID", "IID" = "IID"))
related_covar_df <- covar_df %>%
  inner_join(related_pc_df, by= c("FID" = "FID", "IID" = "IID"))

# Joining df for unrelated and related into one, and writing cov.txt file
covar_df <- unrelated_covar_df %>%
  full_join(related_covar_df)

write.table(covar_df, paste(DATA_DIR, "ukb_cov.txt", sep = "/"), col.names = T, row.names = F, quote = F)


# ---------------------------------------------
# Clear environment and load libraries

rm(list = ls())
library(data.table)
library(tidyverse)
# ---------------------------------------------
# Load config
source("Rscripts/config.R")

# ------------------------------------------------------------------------
#### Load temp files

warf_df <- fread(paste(TEMP_DIR, "01_warf_df.txt", sep = "/"))
warf_df <- data.frame(warf_df)

metadata_df <- fread(paste(TEMP_DIR, "02_metadata_df.txt", sep = "/"), stringsAsFactors=F)
metadata_df <- data.frame(metadata_df)

qc_df <- fread(paste(TEMP_DIR, "03_qc_df.txt", sep = "/"), stringsAsFactors=F)
qc_df <- data.frame(qc_df)

# ---------------------------------------------
## Creating pheno and sample file

# Renaming to eid and converting to character for metadata_df
metadata_df <- metadata_df %>%
  dplyr::rename(eid = V1) %>%
  mutate(eid = as.character(eid))

# Converting eid column to double for the phenotype df
warf_df <- warf_df %>%
  mutate(eid = as.character(eid))

# Inner joining metadata df with phenotype df
meta_samples_df <- metadata_df %>% 
  inner_join(warf_df, by = "eid")

# Renaming to eid and converting to character for QC df
qc_df <- qc_df %>%
  dplyr::rename(eid = sample.id) %>%
  mutate(eid = as.character(eid))

# Inner joining with quality control df
meta_qc_samples_df <- meta_samples_df %>% 
  inner_join(qc_df, by = "eid")

# Creating dfs and writing pheno.txt and subsample.txt files
pheno_df <- meta_qc_samples_df %>% summarize(FID = eid, IID = eid, logDose = avg_daily_dosis) 
sample_df <- meta_qc_samples_df %>% summarize(FID = eid, IID = eid)

write.table(meta_qc_samples_df, paste(TEMP_DIR, "04_meta_qc_samples_df.txt", sep = "/"), col.names = T, row.names = F, quote = F)
write.table(pheno_df, paste(DATA_DIR, "ukb_pheno.txt", sep = "/"), col.names = T, row.names = F, quote = F)
write.table(sample_df, paste(DATA_DIR, "ukb_warf_subsample.txt", sep = "/"), col.names=T, row.names = F, quote = F)

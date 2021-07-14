# ---------------------------------------------
# Clear environment and load libraries

rm(list = ls())
library(data.table)
library(tidyverse)
# ---------------------------------------------
# Load config
source("../config.R")

# ------------------------------------------------------------------------
#### Read files

warf_df <- fread(DEFINED_PHENOTYPE, stringsAsFactors=F)
qc_df <- fread(QC_FILTERED, stringsAsFactors=F)

# ---------------------------------------------
## Creating pheno and sample file

# Converting eid column to double for the phenotype df
warf_df <- warf_df %>%
  mutate(eid = as.character(eid))

# Renaming to eid and converting to character for QC df
qc_df <- qc_df %>%
  dplyr::rename(eid = sample.id) %>%
  mutate(eid = as.character(eid))

# Inner joining with quality control df
warf_qc_df <- warf_df %>% 
  inner_join(qc_df, by = "eid")

# Creating dfs and writing pheno.txt and subsample.txt files
pheno_df <- warf_qc_df %>% summarize(FID = eid, IID = eid, logDose = avg_daily_dosis) 
sample_df <- warf_qc_df %>% summarize(FID = eid, IID = eid)

# Write pheno and subsample id files
write.table(pheno_df, FINAL_PHENOFILE, col.names = T, row.names = F, quote = F)
write.table(sample_df, FINAL_SUBSAMPLE, col.names=T, row.names = F, quote = F)


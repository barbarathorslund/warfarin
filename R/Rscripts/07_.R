rm(list = ls())
library(data.table)
library(tidyverse)
# ---------------------------------------------
# Load config
source("Rscripts/config.R")

# Load and combine bolt output files
all.files <- list.files(path = BOLT_OUT_DATA_DIR, pattern = "bgen.stats.gz", full.names = TRUE)
l <- lapply(all.files, fread)
ukb_combined_bolt_out <- rbindlist(l)

# Write file for 
write.table(ukb_combined_bolt_out, paste(DATA_DIR, "ukb_combined_bolt_out.txt", sep = "/"), col.names = T, row.names = F, quote = F)

# subset significant SNPs only and see how many chromosomes have significant SNPs
sign1 <- ukb_combined_bolt_out %>% filter(P_BOLT_LMM_INF < 5E-08)
table(sign1$CHR)


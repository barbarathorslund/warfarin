# ---------------------------------------------
# Clear environment and load libraries

rm(list = ls())
library(data.table)
library(tidyverse)
# ---------------------------------------------
# Load config
source("Rscripts/config.R")

# ---------------------------------------------

# Read metal out file and subset to N including all studies
metal_out <- fread("/Users/barbara/Desktop/METAANALYSIS2.TBL")
metal_out_subset <- subset(metal_out, N=="18024")

# Split pval
metal_out_subset <- metal_out_subset %>%
  mutate(`P-value`=str_replace(`P-value`, "E", "e")) %>% 
  separate(`P-value`, c("PVAL1", "PVAL2"), "e", fill = "right")
  
# Rematch chromosome by rs
sum_stats <- fread("/Users/barbara/Documents/barbara/warfarin/data/ukb/ukb_warf_sumstat.txt")

sum_stats <- sum_stats %>% 
  select(RS, CHR)

metal_out_subset <- metal_out_subset %>%
  left_join(sum_stats, by= c("MarkerName" = "RS"))

metal_out_subset <- metal_out_subset %>% 
  mutate(PVAL1= as.numeric(PVAL1)) %>% 
  mutate(PVAL2=as.numeric(PVAL2))

sig <- subset(metal_out_subset, PVAL1 < 5 & PVAL2< -8)

head(sig)
table(sig$CHR)

write.table(metal)
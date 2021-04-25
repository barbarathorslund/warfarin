# ---------------------------------------------
# Clear environment and load libraries

rm(list = ls())
library(data.table)
library(tidyverse)
# ---------------------------------------------
# Load config
source("Rscripts/config.R")

# ---------------------------------------------

ukb <- fread("/Users/barbara/Documents/barbara/warfarin/data/ukb/ukb_warf_sumstat.txt")
chb <- fread("/Users/barbara/Documents/barbara/warfarin/data/chb/chb_warf_sumstat.txt")

# Merge PVAL ukb
ukb_merged_pval <- ukb %>% unite(PVAL, PVAL1, PVAL2, sep="e") %>% 
  mutate(PVAL=str_replace(PVAL,fixed("e."),"")) %>% 
  mutate(N=5582)

# Merge PVAL chb
chb_merged_pval <- chb %>% unite(PVAL, PVAL1, PVAL2, sep="e") %>% 
  mutate(PVAL=str_replace(PVAL,fixed("eNA"),"")) %>% 
  mutate(N=12442)

write.table(ukb_merged_pval, "/Users/barbara/Desktop/toscp/ukb_warf_sumstat_mergedPVAL.txt", col.names = T, row.names = F, quote = F)
write.table(chb_merged_pval, "/Users/barbara/Desktop/toscp/chb_warf_sumstat_mergedPVAL.txt", col.names = T, row.names = F, quote = F)


# ---------------------------------------------
# Clear environment and load libraries

rm(list = ls())
library(data.table)
library(tidyverse)
library(Rmpfr)
# ---------------------------------------------
# Load config
source("Rscripts/config.R")

# ---------------------------------------------

# Read metal out file and subset to N including all studies
metal_out <- fread("/Users/barbara/Desktop/METAANALYSIS2.TBL")
metal_out <- metal_out %>% filter(N=="18024")

# Split pval
#metal_out <- metal_out %>%
  #mutate(`P-value`=str_replace(`P-value`, "E", "e")) %>% 
  #separate(`P-value`, c("PVAL1", "PVAL2"), "e", fill = "right")
  
# Rematch chromosome by rs
sum_stats <- fread("/Users/barbara/Documents/barbara/warfarin/data/ukb/ukb_warf_sumstat.txt")

sum_stats <- sum_stats %>% 
  select(RS, CHR, BP)

metal_out <- metal_out %>%
  left_join(sum_stats, by= c("MarkerName" = "RS")) %>% 
  select(-Direction)

write.table(metal_out ,"/Users/barbara/Desktop/meta_warf_sumstat.txt", col.names = T, row.names = F, quote = F)

# Rebase Pval
metal_out1 <- metal_out %>%
  mutate(PVAL = -log10(mpfr(`P-value`)))


  #select(-`P-value`)

#metal_out <- metal_out %>% 
  #mutate(PVAL1= as.numeric(PVAL1)) %>% 
  #mutate(PVAL2=as.numeric(PVAL2))

#sig <- subset(metal_out, PVAL1 < 5 & PVAL2< -8)

#head(sig)
#table(sig$CHR)



  
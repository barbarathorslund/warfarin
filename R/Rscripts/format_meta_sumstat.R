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
metal_out <- fread("/Users/barbara/Documents/barbara/warfarin/data/meta_sumstats/METAANALYSIS2.TBL")
metal_out <- metal_out %>% filter(N=="18024")

# Rematch chromosome by rs, format and write meta sumstat file
ukb_sum_stats <- fread("/Users/barbara/Documents/barbara/warfarin/data/ukb/ukb_warf_sumstat.txt")

ukb_sum_stats <- ukb_sum_stats %>%
  select(RS, CHR, BP)

meta_sumstat <- metal_out %>%
  mutate(SNP=MarkerName, A1=Allele1, A2=Allele2, FREQ=Freq1, BETA=Effect,
         SE=StdErr, P=`P-value`) %>%
  select(-c(MarkerName, Allele1, Allele2, Freq1, Effect, StdErr,
            `P-value`, Direction, FreqSE, MinFreq, MaxFreq)) %>% 
  left_join(ukb_sum_stats, by= c("SNP" = "RS")) %>%
  relocate(SNP,CHR, BP, A1, A2, FREQ,BETA, SE, P, N)


write.table(meta_sumstat ,"/Users/barbara/Documents/barbara/warfarin/data/meta_sumstats/meta_warf_sumstat.txt", col.names = T, row.names = F, quote = F)

## TODO: Run py script to get pval as -log10(pval) for plotting


# Format for LD Hub (LDSC)
meta_sumstat_LD <- meta_sumstat %>%
  summarize(snpid=SNP, A1=A1, A2=A2, b=BETA, N=N, p=P) 

write.table(meta_sumstat_LD, "/Users/barbara/Documents/barbara/warfarin/data/meta_sumstats/meta_warf_sumstat_LD.txt", col.names = T, row.names = F, quote = F, sep = "\t")

# Format for cojo
meta_sumstat_cojo <- meta_sumstat %>%
  summarize(SNP=SNP, A1=A1, A2=A2, freq=FREQ, b=BETA, se=SE, p=P, N=N)

write.table(meta_sumstat_cojo, "/Users/barbara/Documents/barbara/warfarin/data/meta_sumstats/meta_warf_sumstat_cojo.txt", col.names = T, row.names = F, quote = F, sep = "\t")

# Format for MetaXcan
meta_sumstat_metax <- meta_sumstat %>%
  summarize(markername=SNP, chr=CHR, bp_hg19=BP, effect_allele=A1, 
            noneffect_allele=A2, effect_allele_freq=FREQ, p_dgc = P, beta=BETA, standard_error = SE)

write.table(meta_sumstat_metax, "/Users/barbara/Documents/barbara/warfarin/data/meta_sumstats/meta_warf_sumstat_MetaX.txt", col.names = T, row.names = F, quote = F, sep = "\t")




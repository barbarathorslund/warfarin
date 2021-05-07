
# ---------------------------------------------
# Clear environment and load libraries
rm(list = ls())
library(tidyverse)
# ---------------------------------------------
# Load config
source("Rscripts/config.R")

# ---------------------------------------------

#PRS snp list -> only significant SNPs from base data
chb <- fread("/Users/barbara/Documents/barbara/warfarin/data/chb/chb_warf_sumstat.txt")
bim <- fread("/Users/barbara/Documents/barbara/warfarin/data/ukb/prs/genotype/genotype_prs_subsample.QC.bim", header = FALSE)

# Inner join with bim file RS
chb <- chb %>%
  inner_join(bim, by = (c("RS"="V2", "BP"="V4", "CHR"="V1")))

# Get lead SNP for each locus
lead16 <- chb %>% 
  filter(CHR == "16") %>%
  arrange(PVAL2,desc(PVAL1)) %>% 
  slice_head(n = 1)

lead10 <- chb %>% 
  filter(CHR == "10") %>%
  arrange(PVAL2,desc(PVAL1)) %>% 
  slice_head(n =1)

lead19 <- chb %>% 
  filter(CHR == "19") %>%
  arrange(PVAL2,desc(PVAL1)) %>% 
  slice_head(n = 1)

snp_list <- lead16 %>% 
  full_join(lead10) %>% 
  full_join(lead19) #%>% 
  #select(RS)

# Inner join with QCed target SNP list
#snp_list <- snp_list %>%
  #inner_join(comb_lead, by= c("V1"= "RS"))
  #select(V1)

write.table(snp_list, "/Users/barbara/Documents/barbara/warfarin/data/ukb/prs/genotype/genotype_prs_subsample.QC.sig.snplist", col.names = F, row.names = F, quote = F)



# ---------------------------------------------
# Clear environment and load libraries
rm(list=ls())
library(data.table)
library(tidyverse)
library(stringr)
#library(EasyQC)

# ---------------------------------------------
# Load config
source("Rscripts/config.R")

#--------------------------------------------

## Format file for easyQC

# Load file for metaQC
#warf_df <- fread(COMBINED_BOLT)

# Format file with columns: SNP;ALLELE1;ALLELE0;A1FREQ;INFO;BETA;SE;P_BOLT_INF;CHR;BP;N
#warf_df <- warf_df %>% 
 # summarize(SNP=SNP,ALLELE1=ALLELE1,ALLELE0=ALLELE0,A1FREQ=A1FREQ, INFO=INFO,
           #BETA=BETA,SE=SE,P_BOLT_LMM_INF=P_BOLT_LMM_INF,CHR=CHR,BP=BP) %>% 
  #mutate(N=5582)

# PVAL to char
# Make all instances of E lowercase
# Split scientific format P values to two columns
#warf_df <- warf_df %>%
  #mutate(P_BOLT_LMM_INF=str_replace(P_BOLT_LMM_INF, "E", "e")) %>% 
  #separate(P_BOLT_LMM_INF, c("PVAL1", "PVAL2"), "e", fill = "right")


#write.table(warf_df, COMBINED_BOLT_V2, col.names = T, row.names = F, quote = F, sep = "\t")
  
## Perform EasyQC
#EasyQC("Rscripts/easyQC.ecf")

## Annotate rs numbers
sum_stat <- fread("/home/projects/cu_10039/people/bartho/warfarin/data/ukb/easyQC_out/CLEANED.warf.txt")#SUM_STAT_PRE_RSANN
rsmid <- fread("/home/projects/cu_10039/people/bartho/warfarin/data/ukb/raw/rsmid_machsvs_mapb37.1000G_p3v5.merged_mach_impute.v3.corrpos.gz")#RSMID_FILE

# Add chr:pos to both files
rsmid$CHRPOS <- with(rsmid, paste0(chr,":",pos))
sum_stat$CHRPOS <- with(sum_stat, paste0(CHR,":",BP))

# Subset 1000G to include only rs-numbers corresponding to ones in sum_stat
rsmid_subset <- subset(rsmid, CHRPOS %in% sum_stat$CHRPOS)
rsmid_subset <- rsmid_subset[,c("CHRPOS", "rsmid")]
sum_stat <- subset(sum_stat, CHRPOS %in% rsmid_subset$CHRPOS)

# Merge files
sum_stat <- merge(sum_stat, rsmid_subset, by="CHRPOS")

# Fix columns and remove prefix for CHR
sum_stat <- sum_stat[,-c("SNP","Strand","N","CHRPOS")]
setnames(sum_stat, "rsmid", "RS")
sum_stat <- subset(sum_stat, !duplicated(RS))
sum_stat <- sum_stat %>%
  relocate(RS)

# Write
write.table(sum_stat, file = "/home/projects/cu_10039/people/bartho/warfarin/data/ukb/ukb_warf_sumstat.txt", col.names = T, row.names = F, quote = F) #SUM_STAT_POST_RSANN




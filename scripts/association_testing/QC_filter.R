# ---------------------------------------------
# Clear environment and load libraries

rm(list = ls())
library(data.table)
library(tidyverse)
# ---------------------------------------------
# Load config
source("../config.R")

# ---------------------------------------------
## Get qc table with selections

# read necessary tables

sqc <- fread(SQC_FILE_RAW,stringsAsFactors=FALSE)
sqc <- data.frame(sqc)

fam <- fread(FAM_FILE_RAW,stringsAsFactors=FALSE)
fam <- data.frame(fam)

hdr <- fread(HDR_FILE_RAW)

qcTab_file <- GQC_FILE_RAW
qcTab <- fread(qcTab_file, header = T, stringsAsFactors = F)

# Get sample eid
eid <- as.character(fam$V1)
sqc <- cbind.data.frame(eid,sqc)
sqc$eid <- as.character(sqc$eid)

## Add sample names
hdr$eid <- eid
head(hdr)
newNames <- c("eid",colnames(hdr)[c(1:66)])

sqc <- sqc[,c(1,4:ncol(sqc))]
setnames(sqc, colnames(sqc), newNames)

# Df to sum up remaining individuals after each filtering step
QC_filter_info <- sqc %>% summarize(length(eid))

# ---------------------------------------------
# Get ethnicity selection
source("ethnicity_selection.R")

## Subset to the selection of white british
qc_df <- subset(df, eur_select==T)
QC_filter_info <- QC_filter_info %>% mutate(eur = length(qc_df$sample.id))

# ---------------------------------------------
# Remove sex mismatch
qc_df$sexMismatch <- ifelse(!(qc_df$Submitted.Gender==qc_df$Inferred.Gender), 1, 0)
table(qc_df$sexMismatch)
qc_df <- subset(qc_df, sexMismatch==0)
QC_filter_info <- QC_filter_info %>% mutate(sex_mismatch = length(qc_df$sample.id))

# ---------------------------------------------
# Remove sex aneuplodies
qc_df <- subset(qc_df, putative.sex.chromosome.aneuploidy==0)
QC_filter_info <- QC_filter_info %>% mutate(sex_aneu = length(qc_df$sample.id))

# ---------------------------------------------
# Filter for samples identified as outliers as of heterozygosity and missing rate
qc_df <- subset(qc_df, het.missing.outliers==0)
QC_filter_info <- QC_filter_info %>% mutate(het_missing = length(qc_df$sample.id))

# ------------------------------------------------------------------------
#### Write files

write.table(qc_df, QC_FILTERED, col.names = T, row.names = F, quote = F)
write.table(QC_filter_info, QC_FILTER_INFO, col.names = T, row.names = F, quote = F)




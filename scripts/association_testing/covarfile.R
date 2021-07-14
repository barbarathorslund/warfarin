rm(list = ls())
library(data.table)
library(tidyverse)
library(HDF5Array)
library(rhdf5)

# ---------------------------------------------
# Load config
source("../config.R")

# ------------------------------------------------------------------------
## Extract metadata and join with PCs for covariates

# Read meta data file
h5.fn <- METADATA_FILE_RAW
h5ls(h5.fn)
meta_df = as.data.frame(h5read(h5.fn,"sample.id"))
sample.id <- meta_df

## age
h5ls(h5.fn)
h5readAttributes(h5.fn,"f.34/f.34")
yob = h5read(h5.fn,"f.34/f.34")[,1]
names(yob) = sample.id[,1]
meta_df$yob = yob

# Marking missing values as NA 
meta_df$yob[meta_df$yob == -9999] <- NA 

## sex (Male = 1, female = 0)
sex = h5read(h5.fn,"f.31/f.31")[,1]
sexGen = h5read(h5.fn,"f.22001/f.22001")[,1]

names(sex) = meta_df[,1]

meta_df$sex = sex
meta_df$sexGen = sexGen

# Marking missing values as NA 
meta_df$sex[meta_df$sex == -9999] <- NA 
meta_df$sexGen[meta_df$sexGen == -9999] <- NA 

meta_df$sexMismatch <- ifelse(!(meta_df$sex == meta_df$sexGen), 1, 0)
table(meta_df$sexMismatch)

## Assessment center
h5readAttributes(h5.fn,"f.54")
h5readAttributes(h5.fn,"f.54/f.54")
assessCentre = h5read(h5.fn,"f.54/f.54")[,1]
names(assessCentre) = meta_df[,1]
meta_df$assessCenter <- assessCentre

# Marking missing values as NA
meta_df$assessCenter[meta_df$assessCenter == -9999] <- NA

## BMI
h5readAttributes(h5.fn,"f.21001")
h5readAttributes(h5.fn,"f.21001/f.21001")
bmi = h5read(h5.fn,"f.21001/f.21001")[,1]
names(bmi) = meta_df[,1]
meta_df$bmi <- bmi
any(bmi == -9999)

# Marking missing values as NA
meta_df$bmi[meta_df$bmi == -9999] <- NA

# Get genotyping array from QC df and inner join with extracted metadata
qc_df <- fread(QC_FILTERED, stringsAsFactors=F)

meta_df <- meta_df %>%
  mutate(V1 = as.integer(V1)) %>% 
  inner_join(qc_df, by = c("V1" = "sample.id"))

# Getting relevant metadata for covar file
covar_df <- meta_df %>%
  summarize(FID = V1, IID = V1, sex = sex, yob = yob, assessCenter = assessCenter,  bmi = bmi, genotyping.array = genotyping.array)

# Read new subsample specific PCs
unrelated_pc_df <- read_delim(UNRELATED_PC, delim="\t")
related_pc_df <- read_delim(RELATED_PC, delim="\t")

# full joining unrelated and related PCs 
pcs <- unrelated_pc_df %>%
  full_join(related_pc_df)

# Inner goining covar_df with pcs
covar_df <- covar_df %>%
  inner_join(pcs, by= c("FID" = "FID", "IID" = "IID"))

# Check number of missing values in BMI
bmi_NA <- covar_df %>% filter(is.na(bmi))
length(bmi_NA$IID) # 48

# Write covar file
write.table(covar_df, COVARFILE, col.names = T, row.names = F, quote = F)


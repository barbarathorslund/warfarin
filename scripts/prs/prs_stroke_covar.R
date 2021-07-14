# ---------------------------------------------
# Clear environment and load libraries

rm(list = ls())
library(data.table)
library(tidyverse)
library(HDF5Array)
library(rhdf5)

# ---------------------------------------------
# Load config
source("Rscripts/config.R")
# ---------------------------------------------
# Meta data file
h5.fn <- METADATA_FILE_RAW
h5ls(h5.fn)
prs_info = as.data.frame(h5read(h5.fn,"sample.id"))
sample.id <- prs_info

# ---------------------------------------------
## age
yob = h5read(h5.fn,"f.34/f.34")[,1]
names(yob) = sample.id[,1]
prs_info$yob = yob

# Marking missing values as NA 
prs_info$yob[prs_info$yob == -9999] <- NA 

# ---------------------------------------------
## sex (Male = 1, female = 0)

sex = h5read(h5.fn,"f.31/f.31")[,1]
names(sex) = prs_info[,1]
prs_info$sex = sex

# Marking missing values as NA 
prs_info$sex[prs_info$sex == -9999] <- NA

# ---------------------------------------------
## Inner join with event

event <- fread(PRS_STROKE_PHENO)

prs_info <- prs_info %>%
  mutate(V1 = as.integer(V1)) %>% 
  inner_join(event, by = c("V1" = "IID"))

# ---------------------------------------------
## Inner join with PC1-10

pcs <- fread(PRS_STROKE_PC)

prs_info <- prs_info %>% 
  inner_join(pcs, by= c("V1" = "IID"))

# ---------------------------------------------
# Format for covariate file
prs_covar <- prs_info %>%
  summarize(FID=V1, IID=V1, yob=yob, sex=sex, PC1=PC1, PC2=PC2, PC3=PC3,
            PC4=PC4, PC5=PC5, PC6=PC6, PC7=PC7, PC8=PC8, PC9=PC9, PC10=PC10)

# Write covar file for prs target
write.table(prs_covar, PRS_STROKE_COVAR, col.names = T, row.names = F, quote = F)



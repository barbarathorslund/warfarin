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
## Inner join with stroke event

stroke_event <- fread(STROKE_EVENT)

prs_info <- prs_info %>%
  mutate(V1 = as.integer(V1)) %>% 
  inner_join(stroke_event, by = c("V1" = "V1"))

# ---------------------------------------------
## Inner join with PC1-10







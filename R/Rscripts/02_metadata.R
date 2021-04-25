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

##########################
## Extracting meta-data ##
##########################

# Getting meta data file as df
h5.fn <- METADATA_FILE_RAW
h5ls(h5.fn)
metadata_df = as.data.frame(h5read(h5.fn,"sample.id"))
sample.id <- metadata_df

# ---------------------------------------------
## age

h5ls(h5.fn)
h5readAttributes(h5.fn,"f.34/f.34")
yob = h5read(h5.fn,"f.34/f.34")[,1]
names(yob) = sample.id[,1]
metadata_df$yob = yob

# Marking missing values as NA 
metadata_df$yob[metadata_df$yob == -9999] <- NA 

# ---------------------------------------------
## sex (Male = 1, female = 0)

sex = h5read(h5.fn,"f.31/f.31")[,1]
sexGen = h5read(h5.fn,"f.22001/f.22001")[,1]

names(sex) = metadata_df[,1]

metadata_df$sex = sex
metadata_df$sexGen = sexGen

# Marking missing values as NA 
metadata_df$sex[metadata_df$sex == -9999] <- NA 
metadata_df$sexGen[metadata_df$sexGen == -9999] <- NA 

metadata_df$sexMismatch <- ifelse(!(metadata_df$sex == metadata_df$sexGen), 1, 0)
table(metadata_df$sexMismatch)


# ---------------------------------------------
## Assessment center

h5readAttributes(h5.fn,"f.54")
h5readAttributes(h5.fn,"f.54/f.54")
assessCentre = h5read(h5.fn,"f.54/f.54")[,1]
names(assessCentre) = metadata_df[,1]
metadata_df$assessCenter <- assessCentre

# Marking missing values as NA
metadata_df$assessCenter[metadata_df$assessCenter == -9999] <- NA

# ---------------------------------------------
## BMI

h5readAttributes(h5.fn,"f.21001")
h5readAttributes(h5.fn,"f.21001/f.21001")
bmi = h5read(h5.fn,"f.21001/f.21001")[,1]
names(bmi) = metadata_df[,1]
metadata_df$bmi <- bmi
any(bmi == -9999)

# Marking missing values as NA
metadata_df$bmi[metadata_df$bmi == -9999] <- NA

# ------------------------------------------------------------------------
#### Saving temporary dataframe

write.table(metadata_df, METADATA_EXTRACTED, col.names = T, row.names = F, quote = F)




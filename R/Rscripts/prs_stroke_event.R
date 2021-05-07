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

#Loading issue data
df_orig <- fread(ISSUE_FILE_RAW)

#removing dots from bnf_codes
df_orig <- df_orig %>%
  mutate(bnf_code=str_replace_all(bnf_code,fixed("."),""))

#Extracting all warfarin related entries and clean columns
warf_df <- df_orig %>% 
  mutate(drug_name_lower = str_to_lower(drug_name)) %>%
  filter(str_detect(drug_name_lower, "warfarin") |
           str_detect(drug_name_lower, "warf") | 
           str_detect(bnf_code, "0208020V0"))

##---------------------------------------------------------------------------
# Define stroke event
# I63 events: 131366, 131367 (cerebral stroke); 
# I64 events: 131368, 131369 (stroke);

# Getting meta data file as df
h5.fn <- METADATA_FILE_RAW
h5ls(h5.fn)
info_df = as.data.frame(h5read(h5.fn, "sample.id"))
sample.id <- info_df

# Extract I63 events source of report
stroke_I63 = h5read(h5.fn,"f.131367/f.131367")[,1]
names(stroke_I63) = sample.id[,1]
info_df$stroke_I63 = stroke_I63
info_df$stroke_I63[info_df$stroke_I63 == -9999] <- NA

# Extract I64 events source of reports
stroke_I64 = h5read(h5.fn,"f.131369/f.131369")[,1]
names(stroke_I64) = sample.id[,1]
info_df$stroke_I64 = stroke_I64
info_df$stroke_I64[info_df$stroke_I64 == -9999] <- NA

# Extract I63 events date
stroke_I63_date = h5read(h5.fn,"f.131366/f.131366")[,1]
names(stroke_I63_date) = sample.id[,1]
info_df$stroke_I63_date = stroke_I63_date
info_df$stroke_I63_date[info_df$stroke_I63_date == -9999] <- NA 

# Extract I64 events date
stroke_I64_date = h5read(h5.fn,"f.131368/f.131368")[,1]
names(stroke_I64) = sample.id[,1]
info_df$stroke_I64_date = stroke_I64_date
info_df$stroke_I64_date[info_df$stroke_I64_date == -9999] <- NA


# Inner join with issue data
info_df <- info_df %>%
  mutate(V1 = as.integer(V1)) %>% 
  inner_join(warf_df, by = c("V1" = "eid"))

length(unique(info_df$V1)) # 8193

# Add binary column to define if source of report is of interest (40, 41, 30, 31)
info_df <- info_df %>% 
  mutate(stroke_by_report =  case_when(
    # Define stroke events by source of report
    stroke_I63 | stroke_I64 == 40 ~ 1,
    stroke_I63 | stroke_I64 == 41 ~ 1,
    stroke_I63 | stroke_I64 == 30 ~ 1,
    stroke_I63 | stroke_I64 == 31 ~ 1,
    # Define no stroke event
    is.na(stroke_I63) & is.na(stroke_I64) ~ 0,
    # Define unwanted stroke events
    TRUE ~ 2)) %>%
  # Remove unwanted stroke events
  filter(!(stroke_by_report == 2))

length(unique(info_df$V1)) # 7945

# Get stroke event dates for relevant source of report codes
combination <- c(40, 41, 30, 31)

info_df <- info_df %>%
  mutate(stroke_I63_date = 
           case_when(
             !(stroke_I63 %in% combination) ~ NA_character_,
             TRUE ~ stroke_I63_date)) %>% 
  mutate(stroke_I64_date = 
           case_when(
             !(stroke_I64 %in% combination) ~ NA_character_,
             TRUE ~ stroke_I63_date))

# Function for numeric output of difference in days from two dates
diffdays <- function(date1, date2) {
  
  return(as.numeric(difftime(date1,date2,units="days")))
}

# Get binary column of stroke event occurring at a max of 180 days after issue date
info_df <- info_df %>%
  #Select columns needed
  select(V1, stroke_I63_date, stroke_I64_date, issue_date) %>% 
  # Format dates
  mutate(stroke_I63_date = lubridate::ymd(stroke_I63_date)) %>% 
  mutate(stroke_I64_date = lubridate::ymd(stroke_I64_date)) %>% 
  mutate(issue_date = lubridate::dmy(issue_date)) %>% 
  # Make stroke_event (binary) column by threshold for time difference from issue to stroke date
  rowwise() %>% 
  mutate(stroke_event = case_when(
    # No stroke events
    is.na(stroke_I63_date) & is.na(stroke_I64_date) ~ 0,
    # Stroke events
    diffdays(stroke_I63_date,issue_date) >= 0 & diffdays(stroke_I63_date,issue_date) < 180 ~ 1,
    diffdays(stroke_I64_date,issue_date) >= 0 & diffdays(stroke_I64_date,issue_date) < 180 ~ 1,
    # Stroke events to remove
    TRUE ~ 2 )) %>% 
  filter(!(stroke_event == 2))
  
length(unique(info_df$V1)) # 7378

# Collapse stroke event for individuals
info_df <- info_df %>% 
  select(V1, stroke_event) %>%
  group_by(V1) %>% 
  summarize(stroke_event=sum(stroke_event)) %>% 
  mutate(stroke_event = case_when(
    stroke_event == 0 ~ 0,
    TRUE ~ 1
  ))

length(info_df$V1) # 7378  

# Write subset_ID file for PCA
subset_id <- info_df %>%
  summarize(FID = V1, IID = V1)

prs_pheno <- info_df %>%
  summarize(FID=V1, IID=V1, stroke_event=stroke_event)

test <- subset(prs_pheno, prs_pheno$stroke_event==1)
length(test$IID) # 122

# Write files
write.table(subset_id, PRS_STROKE_SUBSAMPLE_ID, col.names = T, row.names = F, quote = F)
write.table(prs_pheno, PRS_STROKE_PHENO, col.names = T, row.names = F, quote = F)



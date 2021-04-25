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

# Getting meta data file as df
#h5.fn <- METADATA_FILE_RAW
#h5ls(h5.fn)
#info_df = as.data.frame(h5read(h5.fn, "sample.id"))
#sample.id <- info_df
# ---------------------------------------------
## Get warfarin treatment subset

# Get treatment file
#h5readAttributes(h5.fn, "f.20003/f.20003")
#index <- list(NULL, seq(from = 1, to = 47))
#treatment <-
#as.data.frame(h5read(h5.fn, "f.20003/f.20003", index = index))

# Get sample ids for treatment
#treatment <- treatment %>%
#mutate(sample_id = sample.id$V1) %>%
#relocate(sample_id)

# Add binary column for treatment with warfarin or not
#treatment <- treatment %>%
#mutate(treatment = pmap_dbl(select(.,-sample_id), ~
#case_when(
#any(c(...) == 1141164760) ~ 1,
#any(c(...) == 1140888266) ~ 1,
#any(c(...) == 1140910832) ~ 1,
#TRUE ~ 0)
#)
#)

# Filter for only warfarin treated ids
#treatment <- treatment %>%
#filter(treatment==1) %>% 
#select(sample_id)

#Loading issue data
df_orig <- fread(ISSUE_FILE_RAW)

#removing dots from bnf_codes
df_orig <- df_orig %>%
  mutate(bnf_code=str_replace_all(bnf_code,fixed("."),""))

#Extracting all warfarin related entries and clean columns (by adding lower case version column of drug_name then filter for warfarin and warf in drug_name and specific bnf code)
warf_df <- df_orig %>% 
  mutate(drug_name_lower = str_to_lower(drug_name)) %>%
  filter(str_detect(drug_name_lower, "warfarin") |
           str_detect(drug_name_lower, "warf") | 
           str_detect(bnf_code, "0208020V0"))

##---------------------------------------------------------------------------
# Define stroke event
# I63 events: 131366, 131367 (cerebral stroke); 
# I64 events: 131368, 131369 (stroke); 
# 53 (date of assessment)

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

# Extract assessment date
#h5readAttributes(h5.fn,"f.53/f.53")
#assessment_date = h5read(h5.fn,"f.53/f.53")[,1]
#names(assessment_date) = sample.id[,1]
#info_df$assessment_date = assessment_date
#info_df$assessment_date[info_df$assessment_date == -9999] <- NA 

# Add binary column to define if source of report is of interest (40 and 41)
#info_df <- info_df %>% 
#mutate(include = pmap_dbl(select(.,-V1), ~
#case_when(
#any(c(...) == 40) ~ 1,
#any(c(...) == 41) ~ 1,
#TRUE ~ 0)
#)
#)

# Inner join with warfarin treated ids (treatment)
#info_df <- info_df %>% 
  #inner_join(treatment, by= c("V1" = "sample_id"))

# Inner join with issue data
info_df <- info_df %>%
  mutate(V1 = as.integer(V1)) %>% 
  inner_join(warf_df, by = c("V1" = "eid"))

# Keep only stroke event dates where source of report is of interest(40 or 41)
combination <- c(40, 41)

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
    diffdays(stroke_I63_date,issue_date) >= 0 & diffdays(stroke_I63_date,issue_date) < 180 ~ 1,
    diffdays(stroke_I64_date,issue_date) >= 0 & diffdays(stroke_I64_date,issue_date) < 180 ~ 1,  
    TRUE ~ 0
  ))

#test <- subset(info_df1, info_df1$stroke_event==1)
#length(unique(test$V1))

# Collapse stroke event for individuals
info_df <- info_df %>% 
  select(V1, stroke_event) %>%
  group_by(V1) %>% 
  summarize(stroke_event=sum(stroke_event)) %>% 
  mutate(stroke_event = case_when(
    stroke_event == 0 ~ 0,
    TRUE ~ 1
  ))
  
# Write subset_ID file for PCA
subset_id <- info_df %>%
  summarize(FID = V1, IID = V1)

write.table(subset_id, PRS_SUBSAMPLE_ID, col.names = T, row.names = F, quote = F)
write.table(info_df, STROKE_EVENT, col.names = T, row.names = F, quote = F)

##---------------------------------------------------------------------------
# Extract yob and sex


## Get stroke event dates from ids with event(s) where source of report is of interest(40/41)
#combination <- c(40, 41)

#info_df <- info_df %>%
# Format dates
#mutate(stroke_I63_date = lubridate::ymd(stroke_I63_date)) %>% 
#mutate(stroke_I64_date = lubridate::ymd(stroke_I64_date)) %>% 
#mutate(assessment_date = lubridate::ymd(assessment_date)) %>% 
#rowwise() %>% 
# Get (earliest if two) stroke event date
#mutate(stroke_date = 
#case_when(
#any(stroke_I64 %in% combination & stroke_I63 %in% combination) ~ min(stroke_I63_date, stroke_I64_date),
#any(stroke_I64 %in% combination) ~ stroke_I64_date,
#any(stroke_I63 %in% combination) ~ stroke_I63_date,
#TRUE ~ NaN,
#)
#)

# Get column of incidence indicating: 
# 0: no event, 1: stroke event after assessment date, 2: stroke event before assessment date
#info_df <- info_df %>%
#mutate(incidence = 
#case_when(
#is.na(stroke_date) ~ 0,
#stroke_date > assessment_date ~ 1,
#stroke_date < assessment_date ~ 2
#)
#)








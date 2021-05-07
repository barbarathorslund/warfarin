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
## Get bleeding dates using ICD-10 codes for bleeding events

h5.fn <- METADATA_FILE_RAW
ukbb = as.data.frame(h5read(h5.fn,"sample.id"))
colnames(ukbb) = "sample.id"
sample.id <- ukbb

source("Rscripts/icd.R")

# Fetch bleed dates using icd10 codes
bleed_date_icd = sapply(seq(nrow(icd_codes_list$ICD10)), function(i) {
  
  idx_bleed = which(substr(icd_codes_list$ICD10[i,],1,3) == "D62"
                   | substr(icd_codes_list$ICD10[i,],1,3) == "I60"
                   | substr(icd_codes_list$ICD10[i,],1,3) == "I61"
                   | substr(icd_codes_list$ICD10[i,],1,3) == "I62"
                   | substr(icd_codes_list$ICD10[i,],1,3) == "N02"
                   | substr(icd_codes_list$ICD10[i,],1,3) == "R31"
                   | substr(icd_codes_list$ICD10[i,],1,3) == "R04"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K250"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K252"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K254"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K256"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K260"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K262"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K264"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K266"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K270"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K272"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K274"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K276"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K280"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K282"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K284"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K286"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K625"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K661"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K920"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K921"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "K922"
                   | substr(icd_codes_list$ICD10[i,],1,4) == "J942"
                   | substr(icd_codes_list$ICD10[i,],1,5) == "K638B"
                   | substr(icd_codes_list$ICD10[i,],1,5) == "K638C")
  date_bleed = icd_codes_list$dateICD10[i,idx_bleed]
  
  # Format dates
  date_bleed <- ifelse(length(as.Date(date_bleed)) > 0,
                      as.character(as.Date(date_bleed)),0 )
  
  return(date_bleed)
})

# Get bleed info
bleed_date <- cbind(ever_bleed = ifelse(bleed_date_icd == 0, 0, 1), 
                        date_bleed = bleed_date_icd)

# ids, to dataframe and ids as column
rownames(bleed_date) = sample.id[,1]
bleed_date <- as.data.frame(bleed_date)
bleed_date <- rownames_to_column(bleed_date, "eid")

table(bleed_date$ever_bleed) #57020 ids with bleeding events


# Inner join issue and bleed date data
bleed_date <- bleed_date %>%
  mutate(eid = as.integer(eid)) %>% 
  inner_join(warf_df, by = "eid")


# Function for numeric output of difference in days from two dates
diffdays <- function(date1, date2) {
  
  return(as.numeric(difftime(date1,date2,units="days")))
}

# Get binary column of bleed event occurring at a max of 180 days after issue date
bleed_date <- bleed_date %>%
  select(eid, date_bleed, issue_date) %>%
  mutate(date_bleed = na_if(date_bleed, 0)) %>% 
  mutate(issue_date = lubridate::dmy(issue_date)) %>% 
  # Make bleed_event (binary) column by threshold for time difference from issue to bleed date
  rowwise() %>% 
  mutate(bleed_event = case_when(
    # No bleed events
    is.na(date_bleed) ~ 0,
    # Stroke events
    diffdays(date_bleed,issue_date) >= 0 & diffdays(date_bleed,issue_date) < 180 ~ 1,
    # Stroke events to remove (bot within 180 days after issue)
    TRUE ~ 2 )) %>% 
  filter(!(bleed_event == 2))

length(unique(bleed_date$eid)) # 6995

# Collapse stroke event for individuals
bleed_date <- bleed_date %>% 
  select(eid, bleed_event) %>%
  group_by(eid) %>% 
  summarize(bleed_event=sum(bleed_event)) %>% 
  mutate(bleed_event = case_when(
    bleed_event == 0 ~ 0,
    TRUE ~ 1
  ))

length(bleed_date$eid) #6995

# Write subset_ID file for PCA
subset_id <- bleed_date %>%
  summarize(FID = eid, IID = eid)

prs_pheno <- bleed_date %>%
  summarize(FID=eid, IID=eid, bleed_event=bleed_event)

test <- subset(prs_pheno, prs_pheno$bleed_event==1)
length(test$IID) # 827

# Write files
write.table(subset_id, PRS_BLEED_SUBSAMPLE_ID, col.names = T, row.names = F, quote = F)
write.table(prs_pheno, PRS_BLEED_PHENO, col.names = T, row.names = F, quote = F)


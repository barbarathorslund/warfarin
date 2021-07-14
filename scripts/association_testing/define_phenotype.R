
# ---------------------------------------------
# Clear environment and load libraries
rm(list = ls())
library(tidyverse)
library(data.table)
# ---------------------------------------------
# Load config
source("../config.R")

print(getwd())

# ---------------------------------------------
## Extracting phenotype
# ------------------------------------------------------------------------
### Loading issue data file, extracting warfarin related entries, clean bnf codes and issue dates

#Loading dataset
df_orig <- fread(ISSUE_FILE_RAW)

# N = 222113
length(unique(df_orig$eid))

#removing dots from bnf_codes
df_orig <- df_orig %>%
  mutate(bnf_code=str_replace_all(bnf_code,fixed("."),""))

#Extracting all warfarin related entries and clean columns
warf_df_orig <- df_orig %>% 
  mutate(drug_name_lower = str_to_lower(drug_name)) %>%
  filter(str_detect(drug_name_lower, "warfarin") |
           str_detect(drug_name_lower, "warf") | 
           str_detect(bnf_code, "0208020V0"))

# Formatting dates in issue_date column
warf_df <- warf_df_orig %>%
  mutate(issue_date = lubridate::dmy(issue_date))

# ------------------------------------------------------------------------
### Dosis column clean up

## Removing all individuals with oral in drug_name_lower and without any specified dose

# Creating df including all eid for which drug_name_lower contains oral
oral_eid_df <- warf_df %>% filter(str_detect(drug_name_lower, "oral")) %>% 
  select(eid) %>%
  unique()

# Creating df including all eid for which no dosis is specified (assuming any value without specified unit is in mg)
no_dose_eid_df <- warf_df %>% filter(!str_detect(drug_name_lower, "\\d")) %>% 
  select(eid) %>%
  unique()

# Removing all entries for eid included in oral_eid_df or no_dose_eid_df
warf_df <- warf_df %>%
  filter(!(eid %in% oral_eid_df$eid)) %>%
  filter(!(eid %in% no_dose_eid_df$eid))

## Extracting dose from drug_name_lower and creating new dosis column in unit mg

# Function for extracting number from input and converting microgram to milligram
microgram_to_milligram <- function(dosis) {
  
  # extract number
  result <- dosis %>%
    str_extract("\\d+") %>% 
    parse_number()
  
  # convert
  result <- result / 1000
  
  return(as.character(result))
}

# extracting dosis from drug_name_lower with regex, removing whitespace, converting to mg if in microgram, removing unit and to numeric value
warf_df <- warf_df %>%
  mutate(dosis = str_extract(drug_name_lower,"(\\d+)(\\w+|\\s|(\\smg))(\\w+)|(\\d+)")) %>%
  mutate(dosis = str_replace_all(dosis, "\\s", "")) %>%
  mutate(dosis = case_when(
    str_detect(dosis,"microgram|micrograms") ~ microgram_to_milligram(dosis),
    TRUE ~ dosis
  )) %>%
  mutate(dosis = str_replace_all(dosis, fixed("mg"), "")) %>% 
  mutate(dosis = as.numeric(dosis))

# ------------------------------------------------------------------------
### Quantity column clean up

## Removing any individuals for which no quantity is given

# Create df containing eids which have entries without quantity (not containing only digit or tab)
no_quantity_1_df <- warf_df %>% filter(!str_detect(quantity, regex("\\d+$|tab", ignore_case = T))) %>%
  select(eid) %>%
  unique()

# Removing all entries for eid included in no_quantity_1_df
warf_df <- warf_df %>%
  filter(!(eid %in% no_quantity_1_df$eid))

## Calculating quantities denoted by multiplication

# Function for extracting numbers and calculate the product
multiply_by <- function(quantity, pattern) {
  a <- str_match(quantity, pattern)[,2]
  b <- str_match(quantity, pattern)[,3]
  
  result <- as.numeric(a) * as.numeric(b)
  
  return(as.character(result))
}

# Finding elements in quantity column to be multiplied (3 special cases covered by regex), and calculating the total quantity
warf_df <- warf_df %>% 
  mutate(quantity = case_when(
    str_detect(quantity, "(\\d+)\\*(\\d+)") ~ multiply_by(quantity, "(\\d+)\\*(\\d+)"), 
    str_detect(quantity, "(\\d+)\\sx\\s(\\d+)") ~ multiply_by(quantity,"(\\d+)\\sx\\s(\\d+)"),
    str_detect(quantity, "(\\d+)\\spack[s]?\\sof\\s(\\d+)") ~ multiply_by(quantity,"(\\d+)\\spack[s]?\\sof\\s(\\d+)"),
    TRUE ~ quantity
  ))

## Handling special case of number written in letters and extracting the number of tablets

# Replacing letter written number
warf_df <- warf_df %>% 
  mutate(quantity = str_replace_all(quantity, "twenty-eight", "28"))

# Extracting tablet number
warf_df <- warf_df %>%
  mutate(quantity = str_extract(quantity, "\\d+")) %>% 
  mutate(quantity = as.numeric(quantity))

## Removing eid with remaining missing quantities

# Create df containing eids which have entries with quantity = 0
no_quantity_2_df <- warf_df %>% filter(quantity == 0) %>%
  select(eid) %>%
  unique()

# Removing all entries for eid included in no_quantity_2_df
warf_df <- warf_df %>%
  filter(!(eid %in% no_quantity_2_df$eid))

# Creating df for eid containing na in quantity column
quantity_na_df <- warf_df %>% filter(is.na(quantity)) %>%
  select(eid) %>%
  unique()

# Removing eid containing na
warf_df <- warf_df %>%
  filter(!(eid %in% quantity_na_df$eid))


# ------------------------------------------------------------------------
### Excluding eid with less than 5 unique issue dates and collapsing potential duplicate entries

# Create df of the count of prescriptions(issues) on unique dates individuals (eid)
unique_issue_date_count_df <- warf_df %>% 
  group_by(eid) %>%
  distinct(issue_date) %>%
  summarize(unique_issue_date_count = length(issue_date))

# Join and filter warf_df for >= 5 unique issue date count
warf_df <- warf_df %>%
  full_join(unique_issue_date_count_df, by="eid") %>%
  filter(unique_issue_date_count >= 5)

# Removing columns not needed
warf_df <- warf_df %>%
  select(-c(data_provider, read_2, bnf_code, dmd_code, drug_name,
            drug_name_lower, unique_issue_date_count))

# Collapsing identical entries (potential duplicates) on same date for eid
warf_df <- warf_df %>%
  group_by(eid, issue_date, dosis, quantity)

# ------------------------------------------------------------------------
### Calculating total dosis, further data collapsing for recurrent, non-duplicate date entries

# Adding new column of the total dosis (dosis*quantity)
warf_df <- warf_df %>%
  mutate(total_dosis = dosis * quantity)

# Collapsing data as of the prescriptions for eid, if on same dates
warf_df <- warf_df %>%
  group_by(eid, issue_date) %>%
  summarize(quantity=sum(quantity), dosis=sum(dosis), total_dosis = sum(total_dosis))

# Including only the 5 most recent prescriptions per eid
warf_df <- warf_df %>%
  group_by(eid) %>%
  slice_max(issue_date, n = 5)

# ------------------------------------------------------------------------
#### Calculating the average daily dosis per prescription

# Adding new column of days passing from one issue to another
warf_df <- warf_df %>%
  arrange(eid, issue_date) %>%
  group_by(eid) %>%
  mutate(diff_days = as.numeric(lead(issue_date) - issue_date))

# Adding new column of the average daily dosis for each issue
warf_df <- warf_df %>%
  arrange(eid, issue_date) %>%
  group_by(eid) %>%
  mutate(avg_daily_dosis_pr_issue = total_dosis/diff_days)

#Removing columns not needed
warf_df <- warf_df %>%
  select(-c(issue_date, quantity, dosis, total_dosis, diff_days))

# filter out NAs in avg_daily_dosis_pr_issue
warf_df <- warf_df %>% filter(!is.na(avg_daily_dosis_pr_issue))

# Collapsing data for each eid at each 4 intervals
warf_df <- warf_df %>%
  group_by(eid) %>%
  summarize(avg_daily_dosis = sum(avg_daily_dosis_pr_issue)/4)

# ------------------------------------------------------------------------
#### Getting avg_dialy_dosis in log scale and removing outliers

# Log transforming response variable (avg_daily_dosis)
warf_df <- warf_df %>% mutate(avg_daily_dosis = log(avg_daily_dosis))

# Defining sd cutoff for outliers
sd_cutoff_dosis <- sd(warf_df$avg_daily_dosis)*3
mean_dosis <- mean(warf_df$avg_daily_dosis)

# Creating df including eid outside 3 sd
sd_outliers <- warf_df %>% 
  filter(avg_daily_dosis > sd_cutoff_dosis+mean_dosis | avg_daily_dosis < mean_dosis-sd_cutoff_dosis) %>%
  select(eid)

# Removing eid included in sd_outliers
warf_df <- warf_df %>%
  filter(!(eid %in% sd_outliers$eid))

# N = 6125
length(unique(warf_df$eid))

# Plotting histogram of avg_daily_dosis to evaluate on distribution
#png(file= paste(PLOTS_DIR,"ukb_hist_responsevar.png", sep = "/"), width = 4, height = 3, units = "in", res = 1200, pointsize = 5)
hist(warf_df$avg_daily_dosis, ylim=range(0,0.8), main="UKB phenotype distribution", xlab="log(dose)", ylab = "density", prob=TRUE, breaks=50, col = "white")
#curve(dnorm(x,mean=mean(warf_df$avg_daily_dosis),sd=sd(warf_df$avg_daily_dosis)), add=TRUE,col="red")
dev.off()

# ------------------------------------------------------------------------
## Write defined phenotype file

write.table(warf_df, DEFINED_PHENOTYPE, col.names = T, row.names = F, quote = F)

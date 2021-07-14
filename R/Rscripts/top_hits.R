library(data.table)
library(tidyverse)

test_chb <- fread("/Users/barbara/Documents/barbara/warfarin/data/chb/chb_warf_sumstat.txt")
test_ukb <- fread("/Users/barbara/Documents/barbara/warfarin/data/ukb/ukb_warf_sumstat.txt")

# Find top x hits for each relevant locus
test_chb <- test_chb %>% 
  mutate(PVAL2 = as.numeric(PVAL2))
test_ukb <- test_ukb %>% 
  mutate(PVAL2 = as.numeric(PVAL2))

# CHB

test16 <- test_chb %>% 
  filter(CHR == "16") %>%
  arrange(PVAL2,desc(PVAL1)) %>% 
  slice_head(n = 949)

test10 <- test_chb %>% 
  filter(CHR == "10") %>%
  arrange(PVAL2,desc(PVAL1)) %>% 
  slice_head(n = 1320)

test19 <- test_chb %>% 
  filter(CHR == "19") %>%
  arrange(PVAL2,desc(PVAL1)) %>% 
  slice_head(n = 6)

chb_comb_test <- test16 %>% 
  full_join(test10) %>% 
  full_join(test19)

# UKB

test16 <- test_ukb %>% 
  filter(CHR == "16") %>%
  arrange(PVAL2,desc(PVAL1)) %>% 
  slice_head(n = 792)

test10 <- test_ukb %>% 
  filter(CHR == "10") %>%
  arrange(PVAL2,desc(PVAL1)) %>% 
  slice_head(n = 958)

ukb_comb_test <- test16 %>% 
  full_join(test10)

test_meta <- fread("/Users/barbara/Documents/barbara/warfarin/data/meta_sumstats/meta_warf_sumstat_log.txt")

test16 <- test_meta %>% 
  filter(CHR == "16") %>%
  arrange(P) %>% 
  slice_tail(n = 6)

test10 <- test_meta %>% 
  filter(CHR == "10") %>%
  arrange(P ) %>% 
  slice_tail(n = 6)

test19 <- test_meta %>% 
  filter(CHR == "19") %>%
  arrange(P) %>% 
  slice_tail(n = 6)

meta_comb_test <- test16 %>% 
  full_join(test10) %>% 
  full_join(test19)


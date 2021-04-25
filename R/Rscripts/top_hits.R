library(data.table)
library(tidyverse)

test <- fread("/Users/barbara/Documents/barbara/warfarin/data/chb/chb_warf_sumstat.txt")

# Find top 5 hits for each relevant locus
test <- test %>% 
  mutate(PVAL2 = as.numeric(PVAL2))

test16 <- test %>% 
  filter(CHR == "16") %>%
  arrange(PVAL2,desc(PVAL1)) %>% 
  slice_head(n = 5)

test10 <- test %>% 
  filter(CHR == "10") %>%
  arrange(PVAL2,desc(PVAL1)) %>% 
  slice_head(n = 5)

test19 <- test %>% 
  filter(CHR == "19") %>%
  arrange(PVAL2,desc(PVAL1)) %>% 
  slice_head(n = 5)

comb_test <- test16 %>% 
  full_join(test10)





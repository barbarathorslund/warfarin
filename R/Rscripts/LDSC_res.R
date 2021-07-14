LDscore <- fread("/Users/barbara/Documents/barbara/warfarin/results/LDhub/LDhub_genetic_correlation.meta_warf_sumstat.csv")

LDscore <- LDscore %>% select(c(trait2,PMID,Category,rg,p,se)) %>% 
  arrange(p) %>% 
  slice_head(n = 97)

write.table(LDscore, "/Users/barbara/Documents/barbara/Other/appendix_tables/LDHub_top97.txt", row.names = FALSE, col.names = TRUE, quote = FALSE, sep = ",")
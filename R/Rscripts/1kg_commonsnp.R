library(data.table)
library(tidyverse)

warf_df <- fread("/home/projects/cu_10039/people/bartho/warfarin/data/ukb/genotype/modelSNP.bim")
oneKG_df <- fread("/home/projects/cu_10039/people/bartho/1KG/Merge.bim")

warf_newname_df <- warf_df %>%
  unite(V7, V1, V4, V6, V5, sep=":", remove = FALSE) %>% 
  select(V2,V7)

write.table(warf_newname_df, "/home/projects/cu_10039/people/bartho/1KG/warf_biplot/warf_ukb_newnames.txt", row.names = FALSE, col.names = FALSE, quote = FALSE)

common_df <- warf_newname_df %>%
  inner_join(oneKG_df, by= c("V7" = "V2")) %>%
  select(V7)

write.table(common_df, "/home/projects/cu_10039/people/bartho/1KG/warf_biplot/warf_ukb_common_snp.txt", row.names = FALSE, col.names = FALSE, quote = FALSE)



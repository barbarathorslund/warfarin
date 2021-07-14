# ---------------------------------------------
# Clear environment and load libraries

rm(list = ls())
library(data.table)
library(tidyverse)
# ---------------------------------------------
# Load config
source("Rscripts/config.R")

# ---------------------------------------------

pics_chr10<- fread(PICS2_CHR10)
pics_chr16<- fread(PICS2_CHR16)
pics_chr19<- fread(PICS2_CHR19)

# SNPs with pics probability > 0
pics_prob_chr10 <- pics_chr10 %>%
  filter(PICS_Prob > 0)
pics_prob_chr16 <- pics_chr16 %>%
  filter(PICS_Prob > 0)
pics_prob_chr19 <- pics_chr19 %>%
  filter(PICS_Prob > 0)

# Combine pics
pics_comb <- pics_prob_chr10 %>%
  full_join(pics_prob_chr16) %>%
  full_join(pics_prob_chr19)

pics_comb_rs <- pics_comb %>% 
  select(Linked_SNP)

write.table(pics_comb_rs, "/Users/barbara/Documents/barbara/warfarin/data/meta_sumstats/pics_rs.snplist", col.names = F, row.names = F, quote = F, sep = "\t")


pics_comb <- pics_comb %>% mutate(Consequence_rn = case_when(
  Consequence == "intron_variant" ~ "intronic",
  Consequence == "downstream_gene_variant" ~ "downstream",
  Consequence == "intergenic_variant" ~ "intergenic",
  Consequence == "upstream_gene_variant" ~ "upstream",
  Consequence == "3_prime_UTR_variant" ~ "UTR3",
  Consequence == "5_prime_UTR_variant" ~ "UTR5",
  Consequence == "missense_variant" ~ "missense",
  Consequence == "synonymous_variant" ~ "synonymous",
  Consequence == "non_coding_transcript_exon_variant" ~ "ncRNA_exonic"
))

length(pics_comb$Linked_SNP)
# Number of linked SNPs: 111

pics_consequence <- ggplot(pics_comb, aes(x=forcats::fct_infreq(Consequence_rn), fill=Consequence_rn)) +
  geom_bar(stat="count")+
  geom_text(stat='count', aes(label=..count..), vjust=-1) +
  theme_minimal() + 
  scale_fill_brewer(palette="Paired") +
  theme(axis.text.x = element_text(size = 0, angle = 90, hjust = .5, vjust = .5, face = "plain"),
      axis.text.y = element_text(size = 12, angle = 0, hjust = 1, vjust = 0, face = "plain"), 
      legend.title=element_text(size=18, face = "bold"), 
      legend.text=element_text(size=12)) + 
  # Legend position
  theme(
    legend.position = c(.95, .95),
    legend.justification = c("right", "top"),
    legend.box.just = "right",
    legend.margin = margin(6, 6, 6, 6)
  )+
  # legend box
  theme(
    legend.box.background = element_rect(color="black", size=0.5),
    legend.box.margin = margin(6, 6, 6, 6)
  )+
  theme(
    # Hide panel borders and remove grid lines
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    # Change axis line
    axis.line = element_line(colour = "black")
  )
  

png(file= paste(PLOTS_DIR,"PICS_consequence.png", sep = "/"), width = 10, height = 5.75, units = "in", res = 400)

pics_consequence + xlab(" ") + theme(legend.title = element_blank())

dev.off()





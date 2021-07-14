# ---------------------------------------------
# Clear environment and load libraries

rm(list = ls())
library(data.table)
library(tidyverse)
# ---------------------------------------------
# Load config
source("Rscripts/config.R")

# ---------------------------------------------

annovar <- fread("/Users/barbara/Documents/barbara/warfarin/results/ANNOVAR/annov.txt")

annotation <- ggplot(annovar, aes(x=forcats::fct_infreq(annot), fill=annot)) +
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


png(file= paste(PLOTS_DIR,"ANNOVAR_annotation.png", sep = "/"), width = 10, height = 5.75, units = "in", res = 400)

annotation + xlab(" ") + theme(legend.title = element_blank())

dev.off()

# Exon variants function

exonic_func <- annovar %>% 
  filter(!(is.na(exonic_func))) %>% 
  select(-c(dist))

table(exonic_func$exonic_func)

write.table(exonic_func, "/Users/barbara/Documents/barbara/warfarin/results/ANNOVAR/ANNOVAR_exon_variants.txt", col.names = TRUE, row.names = FALSE, quote = FALSE)

# Identifying genes with nonsynonymous variants

exonic_func_ns <- exonic_func %>% 
  filter(exonic_func=="nonsynonymous SNV")

table(exonic_func_ns$symbol)

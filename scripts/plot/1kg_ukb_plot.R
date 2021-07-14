rm(list = ls())
library(ggplot2)
library(tidyverse)

# Load config
source("Rscripts/config.R")

options(scipen=100, digits=3)

# read in the eigenvectors, produced in PLINK
eigenvec <- read.table('/Users/barbara/Documents/barbara/warfarin/data/ukb/1kg_biplot/plink.eigenvec', header = FALSE, skip=0, sep = ' ')
rownames(eigenvec) <- eigenvec[,2]
eigenvec <- eigenvec[,3:ncol(eigenvec)]
colnames(eigenvec) <- paste('PC', c(1:20), sep = '')

# read in the PED data
PED <- read.table('/Users/barbara/Documents/barbara/warfarin/data/ukb/1kg_biplot/20130606_g1k.ped', header = TRUE, skip = 0, sep = '\t')

# Get necessary info from PED
PED <- PED %>%  
  select(Individual.ID, Population)


plot_pc <- eigenvec %>% 
  # Add column indicating own sample group
  rownames_to_column("sample_id") %>% 
  mutate(sample = case_when(
  str_detect(as.character(sample_id), "HG") ~ 0,
  str_detect(as.character(sample_id), "NA") ~ 0,
  TRUE ~ 1
  )) %>%
  # Add population column
  left_join(PED, by=c("sample_id" = "Individual.ID")) %>% 
  # Join columns of population groups + own sample
  mutate(population = case_when(
    sample == 1 ~ "UKB*",
    sample == 0 ~ Population
  )) %>% 
  # Get column of super populations (https://www.internationalgenome.org/category/population/)
  mutate(superpopulation = case_when(
    str_detect(population, "ACB|ASW|ESN|GWD|LWK|MSL|YRI") ~ "AFR",
    str_detect(population, "CLM|MXL|PEL|PUR") ~ "AMR",
    str_detect(population, "CDX|CHB|CHS|JPT|KHV") ~ "EAS",
    str_detect(population, "CEU|FIN|GBR|IBS|TSI") ~ "EUR",
    str_detect(population, "BEB|GIH|ITU|PJL|STU") ~ "SAS",
    str_detect(population, "UKB*") ~ "UKB*"
  ))


pc_biplot_pop <- ggplot(plot_pc, aes(PC1, PC2, color=superpopulation)) + geom_point(size=1, alpha=0.6) +
  theme_minimal()+
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
  ) +
  # Point color
  scale_color_manual(breaks=c("AFR", "AMR", "EAS", "EUR", "SAS", "UKB*"),
  values=c("#EEDE04", "#2FA236", "#FD0100", "#F76915", "#333ED4", "#9130d1")) + 
  theme(legend.title=element_text(size=14, face = "bold"), 
        legend.text=element_text(size=12))
  
  
png(file= paste(PLOTS_DIR,"1kg_ukb_biplot.png", sep = "/"), width = 8, height = 6, units = "in", res = 1200)

pc_biplot_pop 

dev.off()


#pc_biplot_subpop <- ggplot(plot_pc, aes(PC1, PC2, color=population)) + geom_point(size=1, alpha=4) +
  #theme_minimal()

#pc_biplot_subpop


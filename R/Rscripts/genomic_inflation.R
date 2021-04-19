library(qqman)
library(data.table)

# Load config
source("Rscripts/config.R")

#Load data
combined_bolt_out <- fread(paste(DATA_DIR, "ukb_combined_bolt_out.txt", sep = "/"))
gwas.dat <- data.frame(combined_bolt_out)

# Calculate genomic inflation factor
chisq <- gwas.dat$CHISQ_BOLT_LMM
lambda = median(chisq)/qchisq(0.5,1)
lambda 

# QQ plot
qqplot <- qq(gwas.dat$P_BOLT_LMM)

png(file= paste(PLOTS_DIR,"qqplot.png", sep = "/"), width = 6, height = 6, units = "in", res = 1200)
qqplot

dev.off()


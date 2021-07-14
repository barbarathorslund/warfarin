rm(list = ls())
library(TwoSampleMR)
library(data.table)
library(MRInstruments)
library(MRPRESSO)
library(gsmr)
library(tidyverse)
library(ggplot2)

# Load config
source("Rscripts/config.R")

#Extract instruments (exposure - here BMI)
ao <- available_outcomes()
ao_bmi <- ao %>% filter(str_detect(trait, "body mass"))

# Get significant independent SNPs for exposure
exposure_dat_bmi <- extract_instruments("ieu-b-40") 

# Standardize bmi
snpfreq = exposure_dat_bmi$eaf.exposure             # allele frequencies of the SNPs
bzx = exposure_dat_bmi$beta.exposure     # effects of the instruments on risk factor
bzx_se = exposure_dat_bmi$se.exposure   # standard errors of bzx
exposure_dat_bmi$n <- 681275
bzx_n = exposure_dat_bmi$n          # GWAS sample size for the risk factor
std_zx = std_effect(snpfreq, bzx, bzx_se, bzx_n)    # perform standardisation
exposure_dat_bmi$std_bzx = std_zx$b    # standardized bzx
exposure_dat_bmi$std_bzx_se = std_zx$se    # standardized bzx_se
head(exposure_dat_bmi)

exposure_dat_bmi <- exposure_dat_bmi[,-c(3,4)]
setnames(exposure_dat_bmi, c("std_bzx","std_bzx_se"),c("beta.exposure","se.exposure"))

#Outcome data - *Warfarin data*. NB! Sample overlap.
outcome_dat_warf <- read_outcome_data(
  snps = exposure_dat_bmi$SNP,
  filename = "/Users/barbara/Documents/barbara/warfarin/data/meta_sumstats/chb_warf_sumstat_log.txt",
  snp_col = "RS",
  beta_col = "BETA",
  se_col = "SE",
  effect_allele_col = "EFFECT_ALLELE",
  other_allele_col = "OTHER_ALLELE",
  eaf_col = "EAF",
  pval_col = "PVAL",
  samplesize_col = "N",
  log_pval = TRUE
)


#Harmonize
dat_bmi <- harmonise_data(
  exposure_dat = exposure_dat_bmi, 
  outcome_dat = outcome_dat_warf,2
)

#Test
res_bmi <- mr(dat_bmi)
res_bmi

write.table(res_bmi, file="/Users/barbara/Documents/barbara/warfarin/results/mr_presso/res_bmi.txt", sep=".", col.names = T, row.names = F, quote=F)

# MR_PRESSO for outlier detection

presso_bmi <- mr_presso(BetaOutcome = "beta.outcome", BetaExposure = "beta.exposure", SdOutcome = "se.outcome",
                     SdExposure = "se.exposure", OUTLIERtest = TRUE, DISTORTIONtest = TRUE, data = dat_bmi, NbDistribution = 1000,  SignifThreshold = 0.05)

presso_bmi

write.table(presso_bmi, file="/Users/barbara/Documents/barbara/warfarin/results/mr_presso/mr_presso_bmi.txt", sep=" ", col.names = T, row.names = F, quote=F)


# Plot like fig1 here: https://www.frontiersin.org/articles/10.3389/fgene.2020.00769/full

cols <- c("#ff9578", "#4281f5", "#bf6986", "#50bf70", "#e6e26a")
labels_ <- c("Weighted median", "Weighted mode", "Simple mode", "MR Egger", "IVW")

mrplot <- ggplot(dat_bmi, aes(beta.exposure, beta.outcome)) +
  theme_minimal() +
  geom_point(alpha=0.8 , color="dimgrey") +
  geom_abline(aes(slope = res_bmi$b[1], intercept=0, group=1, colour="#bf6986"), show.legend = TRUE) +
  geom_abline(aes(slope = res_bmi$b[2], intercept=0, group=2, colour="#4281f5"), show.legend = TRUE) +
  geom_abline(aes(slope = res_bmi$b[3], intercept=0, group=3, colour="#f0ed90"),show.legend = TRUE) +
  geom_abline(aes(slope = res_bmi$b[4], intercept=0, group=4, colour="#ab411d"), show.legend = TRUE) +
  geom_abline(aes(slope = res_bmi$b[5], intercept=0, group=5, colour="#50bf70"), show.legend = TRUE) +
  scale_colour_manual(values=cols, labels=labels_) + 
  # Legend position
  theme(
    legend.position = c(.95, .95),
    legend.justification = c("right", "top"),
    legend.box.just = "right",
    legend.margin = margin(0, 0, 0, 0)
  )+
  # legend box
  theme(
    legend.box.background = element_rect(color="black", size=0.5),
    legend.box.margin = margin(6, 6, 6, 6)
  )+
  # Hide panel borders and remove grid lines
  theme(
  panel.border = element_blank(),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  # Change axis line
  axis.line = element_line(colour = "black")) +
  labs(color="Method") +
  xlab("Effect of exposure [BMI]") +
  ylab("Effect of outcome [warfarin dose]") +
  # text size
  theme(axis.text.x = element_text(size = 12, angle = 0, hjust = .5, vjust = .5, face = "plain"),
        axis.text.y = element_text(size = 12, angle = 0, hjust = 1, vjust = 0, face = "plain"), 
        legend.title=element_text(size=14, face = "bold"), 
        legend.text=element_text(size=12))

png(file= paste(PLOTS_DIR,"mendelianrandomization.png", sep = "/"), width = 10, height = 6, units = "in", res = 1200)

mrplot
dev.off()



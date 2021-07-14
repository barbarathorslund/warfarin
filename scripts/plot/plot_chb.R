rm(list = ls())
library(data.table)
library(tidyverse)
library(normentR)
library(janitor)
library(gg.gap)
library(qqman)

# Load config
source("Rscripts/config.R")

##------------------------------------------------------------------------------
# Manhattan plot. Adapted from:
# https://danielroelfs.com/blog/how-i-create-manhattan-plots-using-ggplot/

gwas_data_load <- fread("/Users/barbara/Desktop/chb_warf_sumstat_log.txt") %>% 
  janitor::clean_names()

gwas_data_load <- gwas_data_load %>%
  mutate(p=pval) %>% 
  select(-pval)

# 
sig_data <- gwas_data_load %>% 
  subset(p > -log10(0.05))
notsig_data <- gwas_data_load %>% 
  subset(p <= -log10(0.05)) %>%
  group_by(chr) %>% 
  sample_frac(0.1)
gwas_data <- bind_rows(sig_data, notsig_data)

# 
data_cum <- gwas_data %>% 
  group_by(chr) %>% 
  summarise(max_bp = max(bp)) %>% 
  mutate(bp_add = lag(cumsum(as.numeric(max_bp)), default = 0)) %>% 
  select(chr, bp_add)

gwas_data <- gwas_data %>% 
  inner_join(data_cum, by = "chr") %>% 
  mutate(bp_cum = bp + bp_add)

# 
axis_set <- gwas_data %>% 
  group_by(chr) %>% 
  summarize(center = mean(bp_cum))
ylim <- abs(floor(max(gwas_data$p))) + 2 
sig <- 5e-8

#
manhplot <- ggplot(gwas_data, aes(x = bp_cum, y = p, 
                                  color = as_factor(chr), size = p)) +
  geom_point(alpha = 0.8, size=1) +
  geom_hline(yintercept = -log10(sig), color = "red3", linetype = "dashed") + 
  scale_x_continuous(label = axis_set$chr, breaks = axis_set$center) +
  scale_y_continuous(expand = c(0,0), limits = c(0, ylim)) +
  scale_color_manual(values = rep(c("#276FBF", "#183059"), unique(length(axis_set$chr)))) +
  scale_size_continuous(range = c(0.5,3)) +
  labs(x = NULL, 
       y = expression(paste("-Log"[10]*"(",italic("P"),")"))) + 
  theme_minimal() +
  theme( 
    legend.position = "none",
    panel.border = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.text.x = element_text(angle = 90, size = 10, vjust = 0.5)
  ) 

png(file= paste(PLOTS_DIR,"chb_manhattan.png", sep = "/"), width = 12, height = 6, units = "in", res = 1200)

# Breaks in y axis
gg.gap(plot=manhplot, segments=list(c(15,125), c(175,375)), ylim=c(0,425), tick_width = c(2.5,25,25), rel_heights=c(0.6,0,0.2,0,0.2))
dev.off()

#TOP at: 412.5013, 167.6737, 11.52932

##------------------------------------------------------------------------------
# Lambda value and QQ plot

# Calculate genomic inflation factor
#chisq <- gwas.dat$CHISQ_BOLT_LMM
#lambda = median(chisq)/qchisq(0.5,1)
#lambda 

## qq
png(file= paste(PLOTS_DIR,"chb_qqplot.png", sep = "/"), width = 6, height = 6, units = "in", res = 1200)
qqnorm(gwas_data$p, main = NULL, xlab = expression(paste("Expected -Log"[10]*"(",italic("P"),")")),
       ylab = expression(paste("Observed -Log"[10]*"(",italic("P"),")")))
qqline(gwas_data$p, col = "red3", lwd=2)
dev.off()

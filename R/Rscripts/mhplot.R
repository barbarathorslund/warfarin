#Manhattan plot by JG
rm(list = ls())
library(data.table)
library(readr)
library(ggrepel)
library(ggplot2)
library(dplyr)
library(RColorBrewer)
library(qqman)
library(basicPlotteR)
library(ggthemes)
library(gg.gap)

# Load config
source("Rscripts/config.R")

#Load data
combined_bolt_out <- fread("/Users/barbara/Desktop/meta_warf_sumstat_log.txt")
gwas.dat <- data.frame(combined_bolt_out)

#Slicing the data to make plotting more computationally efficient
sig.dat <- gwas.dat %>% 
  subset(P < -log10(0.05))
# notsig.dat <- gwas.dat %>% 
#   subset(PVAL >= 0.05) %>%
#   slice(sample(nrow(.), nrow(.) / 10))
# gwas.dat <- rbind(sig.dat,notsig.dat)
gwas.dat <- rbind(sig.dat)


#Preparing the data
nCHR <- length(unique(gwas.dat$CHR))
gwas.dat$BPcum <- NA
s <- 0
nbp <- c()
gwas.dat <- as.data.frame(gwas.dat)

gwas.dat <- gwas.dat[order(gwas.dat$CHR),]

for (i in unique(gwas.dat$CHR)){
  nbp[i] <- max(gwas.dat[gwas.dat$CHR == i,]$BP)
  gwas.dat[gwas.dat$CHR == i,"BPcum"] <- gwas.dat[gwas.dat$CHR == i,"BP"] + s
  s <- s + nbp[i]
}

#Setting parameters for the axis
axis.set <- gwas.dat %>% 
  group_by(CHR) %>% 
  summarize(center = (max(BPcum) + min(BPcum)) / 2)
ylim <- abs(floor(log10(min(gwas.dat$P)))) + 2 
sig <- 5e-8

yname <- expression(paste("-Log"[10]*"(",italic("P"),")"))


#Create a dataset with yes for highlighting SNPs
signal1 <- gwas.dat$BP[which(gwas.dat$RS=="rs9934438") ]
SNP_1<- gwas.dat$SNP[gwas.dat$CHR==1 & 
                        gwas.dat$BP<(signal1+1000000)&gwas.dat$BP>(signal1-1000000)]


signal2 <- gwas.dat$BP[which(gwas.dat$RS=="rs2359612") ]
SNP_2 <- gwas.dat$SNP[gwas.dat$CHR==2 & 
                        gwas.dat$BP<(signal2+1000000)&gwas.dat$BP>(signal2-1000000)]

signal4 <-gwas.dat$BP[which(gwas.dat$RS=="rs9923231") ]
SNP_4 <- gwas.dat$SNP[gwas.dat$CHR=="4" & 
                        gwas.dat$BP<(signal4+1000000)&gwas.dat$BP>(signal4-1000000)]


signal6 <- gwas.dat$BP[which(gwas.dat$RS=="rs749670") ]
SNP_6 <- gwas.dat$SNP[gwas.dat$CHR==6 & 
                        gwas.dat$BP<(signal6+1000000)&gwas.dat$BP>(signal6-1000000)]

signal9 <-gwas.dat$BP[which(gwas.dat$RS=="rs8050894") ]
SNP_9 <- gwas.dat$SNP[gwas.dat$CHR==9 & 
                        gwas.dat$BP<(signal9+1000000)&gwas.dat$BP>(signal9-1000000)]


signal18 <- gwas.dat$BP[which(gwas.dat$RS=="rs9796794") ]
SNP_18 <- gwas.dat$SNP[gwas.dat$CHR==18 & 
                        gwas.dat$BP<(signal18+1000000)&gwas.dat$BP>(signal18-1000000)]

signal20 <- gwas.dat$BP[which(gwas.dat$RS=="rs56813533") ]
SNP_20 <- gwas.dat$SNP[gwas.dat$CHR==20 & 
                        gwas.dat$BP<(signal20+1000000)&gwas.dat$BP>(signal20-1000000)]

gwas.dat$highlight <- ifelse(gwas.dat$SNP %in% SNP_1 | gwas.dat$SNP %in% SNP_2 | gwas.dat$SNP %in% SNP_4 |
                               gwas.dat$SNP %in% SNP_6 | gwas.dat$SNP %in% SNP_9 | gwas.dat$SNP %in% SNP_18 |
                               gwas.dat$SNP %in% SNP_20, "yes","no")

table(gwas.dat$highlight)

#Annotate top hits
gwas.dat$annotate <- ifelse(gwas.dat$SNP=="rs9934438" | gwas.dat$SNP=="rs2359612" | gwas.dat$SNP=="rs9923231" 
                            | gwas.dat$SNP=="rs749670" | gwas.dat$SNP=="rs8050894" | gwas.dat$SNP=="rs9796794" 
                            | gwas.dat$SNP=="rs56813533", "yes", "no")

table(gwas.dat$annotate)


#Plot the data
manhplot <- ggplot(gwas.dat, aes(x = BPcum, y =-log10(P_BOLT_LMM), 
                                 color = as.factor(CHR))) +
  geom_point(alpha = 0.8) +
  geom_hline(yintercept = -log10(sig), color = "red3", linetype = "dashed", size=0.3) + 
  scale_x_continuous(label = axis.set$CHR, breaks = axis.set$center) +
  scale_y_continuous(limits = c(0, 125)) +#, breaks=seq(0,125,25))+
  scale_color_manual(values = rep(c("grey22", "grey44"), nCHR)) +
  scale_size_continuous(range = c(0.5,3)) +
  geom_point(data=subset(gwas.dat, highlight=="yes"), color="#92DBFF") +
  geom_point(data=subset(gwas.dat, annotate=="yes"), color="red4", shape=18, size=3) +
  labs(x = NULL, 
       y = yname) + 
  theme_light(base_family = "Helvetica")+
 expand_limits(x = 0, y = 0)+
  theme( 
    legend.position = "none",
    axis.line = element_line(size=0.2),
    axis.ticks = element_line(colour="black"),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 12, vjust = 0.5, colour = "black"),
    axis.text.y = element_text(size = 12, colour = "black"),
    axis.title.y = element_text(size=16),
    axis.title.x = element_text("Chromosome", size=10, colour="black")
    

  )

manhplot

png(file= paste(PLOTS_DIR,"ukb_manhattan.png", sep = "/"), width = 12, height = 6, units = "in", res = 1200)
gg.gap(plot=manhplot, segments=c(75,110), ylim=c(0,125), rel_heights=c(0.9,0,0.1))

dev.off()

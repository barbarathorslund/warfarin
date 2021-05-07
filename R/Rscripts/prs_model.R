
# ---------------------------------------------
# Clear environment and load libraries
rm(list = ls())
library(tidyverse)
library(data.table)
library(Publish)
# ---------------------------------------------
# Load config
source("Rscripts/config.R")

# ---------------------------------------------

prs <- fread(PRS_PROFILE)
pheno <- fread(PRS_BLEED_PHENO)
covar <- fread(PRS_BLEED_COVAR)

prs <- prs %>%
  inner_join(pheno, by = c("FID" = "FID", "IID" = "IID")) %>%
  inner_join(covar, by = c("FID" = "FID", "IID" = "IID")) %>% 
  select(-PHENO)

# Standardize score
prs <- prs %>% 
  mutate(SCORE_SD = (SCORE-mean(SCORE))/sd(SCORE) )

# Plot distribution
hist(prs$SCORE_SD, breaks=30)

# Model
model1 <- glm(bleed_event ~ SCORE_SD+sex+yob+PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10, family="binomial", data=prs)
publish(model1)

# Get groups
quantile(prs$SCORE_SD, probs=c(0.05,0.95))
prs[,prsQ:=cut(prs$SCORE_SD, breaks=c(-Inf,-1.738675,1.499835,Inf), labels=c("Q1","Q2","Q3"))]
table(prs$prsQ)

# Model2 with groups
model2 <- glm(bleed_event ~ prsQ,family="binomial", data=prs)
publish(model2)


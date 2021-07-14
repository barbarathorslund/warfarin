
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
## Stroke event
prs_stroke <- fread(PRS_STROKE_PROFILE)
pheno_stroke <- fread(PRS_STROKE_PHENO)
covar_stroke <- fread(PRS_STROKE_COVAR)

prs_stroke <- prs_stroke %>%
  inner_join(pheno_stroke, by = c("FID" = "FID", "IID" = "IID")) %>%
  inner_join(covar_stroke, by = c("FID" = "FID", "IID" = "IID")) %>% 
  select(-PHENO)

# Standardize score
prs_stroke <- prs_stroke %>% 
  mutate(SCORE_SD = (SCORE-mean(SCORE))/sd(SCORE) )

# Plot distribution
hist(prs_stroke$SCORE_SD, breaks=30)

# Model
model1 <- glm(stroke_event ~ SCORE_SD+sex+yob+PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10, family="binomial", data=prs_stroke)
publish(model1)

# Get groups
quantile(prs_stroke$SCORE_SD, probs=c(0.05,0.95))
prs_stroke[,prsQ:=cut(prs_stroke$SCORE_SD, breaks=c(-Inf,-1.740795,1.496930,Inf), labels=c("Q1","Q2","Q3"))]
table(prs_stroke$prsQ)

# Model2 with groups
model2 <- glm(stroke_event ~ prsQ,family="binomial", data=prs_stroke)
publish(model2)

# Two sample t test
prs_stroke_yes <- prs_stroke %>% filter(stroke_event==1) %>% 
  select(SCORE_SD)
prs_stroke_no <- prs_stroke %>% filter(stroke_event==0) %>% 
  select(SCORE_SD)
  
t.test(prs_stroke_yes, prs_stroke_no, alternative = "two.sided", var.equal = FALSE)

#------------------------------------------------
## Bleed event
prs_bleed <- fread(PRS_BLEED_PROFILE)
pheno_bleed <- fread(PRS_BLEED_PHENO)
covar_bleed <- fread(PRS_BLEED_COVAR)

prs_bleed <- prs_bleed %>%
  inner_join(pheno_bleed, by = c("FID" = "FID", "IID" = "IID")) %>%
  inner_join(covar_bleed, by = c("FID" = "FID", "IID" = "IID")) %>% 
  select(-PHENO)

# Standardize score
prs_bleed <- prs_bleed %>% 
  mutate(SCORE_SD = (SCORE-mean(SCORE))/sd(SCORE) )

# Plot distribution
hist(prs_bleed$SCORE_SD, breaks=30)

# Model
model1 <- glm(bleed_event ~ SCORE_SD+sex+yob+PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10, family="binomial", data=prs_bleed)
publish(model1)

# Get groups
quantile(prs_bleed$SCORE_SD, probs=c(0.05,0.95))
prs_bleed[,prsQ:=cut(prs_bleed$SCORE_SD, breaks=c(-Inf,-1.738675,1.499835,Inf), labels=c("Q1","Q2","Q3"))]
table(prs_bleed$prsQ)

# Model2 with groups
model2 <- glm(bleed_event ~ prsQ,family="binomial", data=prs_bleed)
publish(model2)

# Two sample t test
prs_bleed_yes <- prs_bleed %>% filter(bleed_event==1) %>% 
  select(SCORE_SD)
prs_bleed_no <- prs_bleed %>% filter(bleed_event==0) %>% 
  select(SCORE_SD)

t.test(prs_bleed_yes, prs_bleed_no, alternative = "two.sided", var.equal = FALSE)

#------------------------------------------------------------------------
# Plot event vs score boxplots

# Stroke event boxplots
prs_stroke <- prs_stroke %>% mutate(event_type="Stroke")

prs_bleed <- prs_bleed %>% mutate(event_type="Bleeding") %>% 
  mutate()

prs_events <- prs_stroke %>% full_join(prs_bleed) %>% 
  mutate(Event = case_when(
    stroke_event == 0 | bleed_event == 0 ~ 0,
    stroke_event == 1 | bleed_event == 1 ~ 1
  )) %>% 
  mutate(Event = as.factor(Event)) %>% 
  mutate(event_type = as.factor(event_type))

event_boxp <- ggplot(prs_events, aes(x=event_type, y=SCORE_SD, fill=Event)) +
  geom_boxplot() +
  theme_classic() +
  ylim(c(-4.5,3.5)) +
  xlab(" ") +
  ylab("PRS") +
  theme(axis.text.x = element_text(size = 12, angle = 90, hjust = .5, vjust = .5, face = "plain"),
        axis.text.y = element_text(size = 12, angle = 0, hjust = 1, vjust = 0, face = "plain"), 
        legend.title=element_text(size=14, face = "bold"), 
        legend.text=element_text(size=12))


png(file= paste(PLOTS_DIR,"prs_event_boxplot.png", sep = "/"), width = 6, height = 5, units = "in", res = 1200)
event_boxp
dev.off()




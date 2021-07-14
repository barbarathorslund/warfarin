p.threshold <- c(5e-08)
# Read in the phenotype file 
phenotype <- read.table("/home/projects/cu_10039/people/bartho/warfarin/data/ukb/prs/prs_target_pheno.txt", header=T)
# Read in the PCs
#pcs <- read.table("/home/projects/cu_10039/people/bartho/warfarin/data/ukb/prs/prs_target_covar.txt", header=F)
# The default output from plink does not include a header
# To make things simple, we will add the appropriate headers
# (1:6 because there are 6 PCs)
#colnames(pcs) <- c("FID", "IID", paste0("PC",1:10)) 
# Read in the covariates (here, it is sex)
covariate <- read.table("/home/projects/cu_10039/people/bartho/warfarin/data/ukb/prs/prs_target_covar.txt", header=T)
# Now merge the files
pheno <- merge(phenotype, covariate, by=c("FID", "IID"))
# We can then calculate the null model (model with PRS) using a linear regression 
# (as height is quantitative)
null.model <- lm(stroke_event~., data=pheno[,!colnames(pheno)%in%c("FID","IID")])
# And the R2 of the null model is 
null.r2 <- summary(null.model)$r.squared
prs.result <- NULL
for(i in p.threshold){
    # Go through each p-value threshold
    prs <- read.table(paste0("/home/projects/cu_10039/people/bartho/warfarin/data/prs/plink/prs_stroke.",i,".profile"), header=T)
    # Merge the prs with the phenotype matrix
    # We only want the FID, IID and PRS from the PRS file, therefore we only select the 
    # relevant columns
    pheno.prs <- merge(pheno, prs[,c("FID","IID", "SCORE")], by=c("FID", "IID"))
    # Now perform a linear regression on Height with PRS and the covariates
    # ignoring the FID and IID from our model
    model <- lm(stroke_event~., data=pheno.prs[,!colnames(pheno.prs)%in%c("FID","IID")])
    # model R2 is obtained as 
    model.r2 <- summary(model)$r.squared
    # R2 of PRS is simply calculated as the model R2 minus the null R2
    prs.r2 <- model.r2-null.r2
    # We can also obtain the coeffcient and p-value of association of PRS as follow
    prs.coef <- summary(model)$coeff["SCORE",]
    prs.beta <- as.numeric(prs.coef[1])
    prs.se <- as.numeric(prs.coef[2])
    prs.p <- as.numeric(prs.coef[4])
    # We can then store the results
    prs.result <- rbind(prs.result, data.frame(Threshold=i, R2=prs.r2, P=prs.p, BETA=prs.beta,SE=prs.se))
}
# Best result is:
prs.result[which.max(prs.result$R2),]
write.table(prs.result, "/home/projects/cu_10039/people/bartho/warfarin/data/prs/plink/prs_result.txt", col.names = T, row.names = F , quote = F)
q() # exit R

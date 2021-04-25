# Read in file
valid <- read.table("/home/projects/cu_10039/people/bartho/warfarin/data/ukb/prs/genotype/genotype_prs_subsample.valid.sample", header=T)
dat <- read.table("/home/projects/cu_10039/people/bartho/warfarin/data/ukb/prs/genotype/genotype_prs_subsample.QC.sexcheck", header=T)
valid <- subset(dat, STATUS=="OK" & FID %in% valid$FID)
write.table(valid[,c("FID", "IID")], "/home/projects/cu_10039/people/bartho/warfarin/data/ukb/prs/genotype/genotype_prs_subsample.QC.valid", row.names=F, col.names=F, sep="\t", quote=F) 
q() # exit R

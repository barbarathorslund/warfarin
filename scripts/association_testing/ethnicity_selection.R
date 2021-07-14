# ---------------------------------------------
#Load libraries
library(HDF5Array)
library(rhdf5)
library(RColorBrewer)
library(R.utils)

# ---------------------------------------------

# Load metadata file
h5.fn <- METADATA_FILE_RAW
h5ls(h5.fn)

# only if keeping related set cases.unrel=cases 

# cases.unrel=cases
sample.id <- sqc[,"eid"]

# ---------------------------------------------
# Extracting ethnicity meta data

ph_cols <- data.frame(
  sample.id=h5read(h5.fn,"sample.id"),
  ethnic=h5read(h5.fn,"f.21000/f.21000")[,1], # self-report ethnicity
  stringsAsFactors = F
) 

# ---------------------------------------------
# Define the qc pass criteria

qc_pass <- (sqc$het.missing.outliers==0 &
              sqc$excluded.from.kinship.inference==0 &
              sqc$excess.relatives==0
              )

# Extract table of passed qc
qc <- sqc[qc_pass,]

# Subset etnicity data for id passing qc
ph = subset(ph_cols, sample.id %in% qc$eid)

# Merge ethnicity data with qc data
df <- merge(ph, qc, by.y="eid", by.x="sample.id")

# Get self-report whites and missing ethnicities (code specific)
df$white <- (df$ethnic %in% c(1,1001,1002,1003)) 
df$ethnic_miss <- (df$ethnic %in% c(-3,-1,NA))

# Get genetically cacuasiaun individuals
df$genCac <- rep(0, nrow(df))
samplesGenCac <- qcTab$sample.id[qcTab$genCacuasian == 1]

# Count ids in df genetically cacuasian
sum(df$sample.id %in% samplesGenCac)
df$genCac[df$sample.id %in% samplesGenCac] <- 1

# Setting standard deviation for the selection
ells <- 5
sds_brit <- 6

# Get mean and SD of each PC among the curated white British sample and self-reported whites
pc_nams <- paste("PC",1:40,sep="")
mm_white <- colMeans(df[df$white==1,pc_nams])
ss_white <- apply(df[df$white==1,pc_nams],2,sd)
mm_brit <- colMeans(df[df$in.white.British.ancestry.subset==1,pc_nams])
ss_brit <- apply(df[df$in.white.British.ancestry.subset==1,pc_nams],2,sd)

# Define ellipses for self reported and curated
dd_white <- rep(0,nrow(df))
dd_brit <- rep(0,nrow(df))
for(i in 1:ells){
  dd_white <- dd_white + (df[,pc_nams[i]]-mm_white[i])^2/(ss_white[i]^2)
  dd_brit <- dd_brit + (df[,pc_nams[i]]- mm_brit[i])^2/(ss_brit[i]^2)
}

# Make selection (intersection of: curated white british ellipse, self-reported white ellipse and self-reported white)
df$eur_select <-(dd_brit < sds_brit^2) & (df$white | df$ethnic_miss)

#(dd_white < sds_white^2)

# ---------------------------------------------
# Plot the selection in PCA space

 set <- rep(1,nrow(df))
 set[df$genCac == 1] <- 4
 set[df$white] <- 4
 set[df$eur_select] <- 2
 cols <- c("gray80",brewer.pal("Dark2",n=4)[1],brewer.pal("Dark2",n=4)[2], brewer.pal("Dark2",n=4)[3],
           brewer.pal("Dark2",n=4)[4])
 
 samp=sample(nrow(df),replace=F)
 plot(df[samp,c("PC1","PC2")],col=cols[set[samp]],cex=.3,
      xlim = c(-20,20), ylim = c(-20,20))

 png(paste(PLOTS_DIR, "ukb39588_eur_selection_pca.png", sep = "/"),width=18,height=10,res=300,units="in")
 pairs(df[samp,c("PC1","PC2","PC3","PC4","PC5")],col=cols[set[samp]],cex=.1)
 dev.off()

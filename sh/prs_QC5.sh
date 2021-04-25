module load tools
module load ngs
module load plink2/1.90beta5.3

datapath=../data/ukb/prs/genotype

cd $datapath

# Remove related
plink \
    --bfile genotype_prs_subsample \
    --extract genotype_prs_subsample.QC.prune.in \
    --keep genotype_prs_subsample.QC.valid \
    --rel-cutoff 0.125 \
    --out genotype_prs_subsample.QC

# Generate final QC'ed prs target data
plink \
    --bfile genotype_prs_subsample \
    --make-bed \
    --keep genotype_prs_subsample.QC.rel.id \
    --out genotype_prs_subsample.QC \
    --extract genotype_prs_subsample.QC.snplist


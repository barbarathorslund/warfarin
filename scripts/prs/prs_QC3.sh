module load tools
module load ngs
module load plink2/1.90beta5.3

datapath=../data/ukb/prs/genotype_stroke

cd $datapath

# Check for sex mismatch
plink \
    --bfile genotype_prs_subsample \
    --extract genotype_prs_subsample.QC.prune.in \
    --keep genotype_prs_subsample.valid.sample \
    --check-sex \
    --out genotype_prs_subsample.QC

module load tools
module load ngs
module load plink2/1.90beta5.3

datapath=../data/ukb/prs/genotype_stroke

cd $datapath

# Standard GWAS QC
plink \
    --bfile genotype_prs_subsample \
    --maf 0.01 \
    --hwe 1e-6 \
    --geno 0.01 \
    --mind 0.1 \
    --write-snplist \
    --make-just-fam \
    --out genotype_prs_subsample.QC

# Pruning to remove highly correlated SNPs
plink \
    --bfile genotype_prs_subsample \
    --keep genotype_prs_subsample.QC.fam \
    --extract genotype_prs_subsample.QC.snplist \
    --indep-pairwise 200 50 0.25 \
    --out genotype_prs_subsample.QC

# Calculate heterozygosity rates
plink \
    --bfile genotype_prs_subsample \
    --extract genotype_prs_subsample.QC.prune.in \
    --keep genotype_prs_subsample.QC.fam \
    --het \
    --out genotype_prs_subsample.QC

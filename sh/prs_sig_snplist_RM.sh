module load tools
module load ngs
module load plink2/1.90beta5.3

datapath=../data/ukb/prs/genotype

cd $datapath

plink \
    --bfile genotype_prs_subsample \
    --make-bed \
    --keep genotype_prs_subsample.QC.rel.id \
    --out genotype_prs_subsample.QC.sig \
    --extract genotype_prs_subsample.QC.sig.snplist

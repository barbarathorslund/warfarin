cd /home/projects/cu_10039/people/bartho/warfarin/data/prs/plink_stroke

# Get file of RS and PVAL
awk '{print $1,$10}' /home/projects/cu_10039/people/bartho/warfarin/data/chb/chb_warf_sumstat_mergedPVAL.txt > SNP.pvalue

module load tools
module load ngs
module load plink2/1.90beta5.4

echo "5e-08 0 5e-08" > range_list 

plink \
    --bfile ../../ukb/prs/genotype_stroke/genotype_prs_subsample.QC \
    --clump-p1 1 \
    --clump-r2 0.1 \
    --clump-kb 250 \
    --clump ../../chb/chb_warf_sumstat_mergedPVAL.txt \
    --clump-snp-field RS \
    --clump-field PVAL \
    --out prs

awk 'NR!=1{print $3}' prs.clumped > prs.valid.snp

# Get PRSs
plink \
    --bfile ../../ukb/prs/genotype_stroke/genotype_prs_subsample.QC \
    --score ../../chb/chb_warf_sumstat_mergedPVAL.txt 1 5 8 header \
    --q-score-range range_list SNP.pvalue \
    --extract prs.valid.snp \
    --out prs

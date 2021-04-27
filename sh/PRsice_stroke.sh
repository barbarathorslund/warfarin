cd /home/projects/cu_10039/people/bartho/warfarin/data/prs

script PRSice.R --dir . \
    --prsice ./PRSice \
    --base /home/projects/cu_10039/people/bartho/warfarin/data/chb/chb_warf_sumstat_mergedPVAL.txt \
    --a1 EFFECT_ALLELE \
    --a2 OTHER_ALLELE \
    --bp BP \
    --chr CHR \
    --pvalue PVAL \
    --stat BETA \
    --beta \
    --snp RS
    --target /home/projects/cu_10039/people/bartho/warfarin/data/ukb/prs/genotype/genotype_prs_subsample.QC \
    --thread 4 \
    --binary-target T \
    --pheno /home/projects/cu_10039/people/bartho/warfarin/data/ukb/prs/prs_target_pheno.txt \
    --covar /home/projects/cu_10039/people/bartho/warfarin/data/ukb/prs/prs_target_covar.txt \
    --bar-levels 5e-08 \
    --fastscore \
    --no-full \
    --score std

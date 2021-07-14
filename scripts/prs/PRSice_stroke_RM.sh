module load tools
module load ngs
module load gcc
module load intel/perflibs
module load R/4.0.3
module load prsice/2.3.3

cd /home/projects/cu_10039/people/bartho/warfarin/data/prs

Rscript /services/tools/prsice/2.3.2/PRSice.R \
    --prsice /services/tools/prsice/2.3.2/PRSice_linux \
    --base /home/projects/cu_10039/people/bartho/warfarin/data/chb/chb_warf_sumstat_mergedPVAL.txt \
    --a1 EFFECT_ALLELE \
    --a2 OTHER_ALLELE \
    --bp BP \
    --chr CHR \
    --pvalue PVAL \
    --stat BETA \
    --snp RS \
    --target /home/projects/cu_10039/people/bartho/warfarin/data/ukb/prs/genotype/genotype_prs_subsample.QC.sig \
    --thread 4 \
    --print-snp \
    --binary-target T \
    --pheno /home/projects/cu_10039/people/bartho/warfarin/data/ukb/prs/prs_target_pheno.txt \
    --cov /home/projects/cu_10039/people/bartho/warfarin/data/ukb/prs/prs_target_covar.txt \
    --bar-levels 5e-08 \
    --fastscore \
    --score std

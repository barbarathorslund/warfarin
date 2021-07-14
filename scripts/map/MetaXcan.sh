#!/bin/sh
#!/bin/sh
#PBS -W group_list=cu_10039 -A cu_10039
### set erorr and output files
#PBS -e /home/projects/cu_10039/people/bartho/warfarin/sh/log/cojo.e
#PBS -o /home/projects/cu_10039/people/bartho/warfarin/sh/log/cojo.o
###set name of the job
#PBS -N cojo
### set number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=4,mem=8gb,walltime=2:00:00
###send an email when the job is done
#PBS -m ae -M barbarathorslund@hotmail.com

module load tools
module load ngs

module load tools
module load anaconda3/2020.07

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/services/tools/anaconda3/2020.07/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/services/tools/anaconda3/2020.07/etc/profile.d/conda.sh" ]; then
        . "/services/tools/anaconda3/2020.07/etc/profile.d/conda.sh"
    else
       	export PATH="/services/tools/anaconda3/2020.07/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export LD_LIBRARY_PATH=/home/projects/cu_10039/people/bartho/venv/lib:$LD_LIBRARY_PATH

conda activate /home/projects/cu_10039/people/bartho/venv

# Here you could write HPC directives if running on a compute cluster
GWAS_TOOLS=../../summary-gwas-imputation/src
METAXCAN=../../MetaXcan-master/software
DATA=../../MetaXcan-master/data
OUTPUT=../data/MetaXcan

# Harmonization
python $GWAS_TOOLS/gwas_parsing.py \
-gwas_file $DATA/gwas/meta_warf_MetaX.txt.gz \
-liftover $DATA/liftover/hg19ToHg38.over.chain.gz \
-snp_reference_metadata $DATA/reference_panel_1000G/variant_metadata.txt.gz METADATA \
-output_column_map markername variant_id \
-output_column_map noneffect_allele non_effect_allele \
-output_column_map effect_allele effect_allele \
-output_column_map beta effect_size \
-output_column_map p_dgc pvalue \
-output_column_map chr chromosome \
--chromosome_format \
-output_column_map bp_hg19 position \
-output_column_map effect_allele_freq frequency \
--insert_value sample_size 18024 \
-output_order variant_id panel_variant_id chromosome position effect_allele non_effect_allele frequency effect_size standard_error pvalue zscore sample_size n_cases \
-output $OUTPUT/harmonized_gwas/meta_warf_additive.txt.gz

# Imputation
#python $GWAS_TOOLS/gwas_summary_imputation.py \
#-by_region_file $DATA/eur_ld.bed.gz \
#-gwas_file $OUTPUT/harmonized_gwas/meta_warf_additive.txt.gz \
#-parquet_genotype $DATA/reference_panel_1000G/chr1.variants.parquet \
#-parquet_genotype_metadata $DATA/reference_panel_1000G/variant_metadata.parquet \
#-window 100000 \
#-parsimony 7 \
#-chromosome 16 \
#-regularization 0.1 \
#-frequency_filter 0.01 \
#-sub_batches 10 \
#-sub_batch 0 \
#--standardise_dosages \
#-output $OUTPUT/summary_imputation/meta_warf_additive_chr16.txt.gz

# Imputation post-processing
#python $GWAS_TOOLS/gwas_summary_imputation_postprocess.py \
#-gwas_file $OUTPUT/harmonized_gwas/meta_warf_additive.txt.gz \
#-folder $OUTPUT/summary_imputation \
#-pattern meta_warf_additive* \
#-parsimony 7 \
#-output $OUTPUT/processed_summary_imputation/meta_warf_additive.txt.gz

#PrediXcan
python $METAXCAN/SPrediXcan.py \
--gwas_file $OUTPUT/harmonized_gwas/meta_warf_additive.txt.gz \
--snp_column panel_variant_id \
--effect_allele_column effect_allele \
--non_effect_allele_column non_effect_allele \
--beta_column effect_size \
--se_column standard_error \
--model_db_path $DATA/models/eqtl/mashr/mashr_Liver.db \
--covariance $DATA/models/eqtl/mashr/mashr_Liver.txt.gz \
--additional_output \
--keep_non_rsid \
--model_db_snp_key varID \
--throw \
--output_file $OUTPUT/spredixcan/eqtl/meta_warf_additive__PM__Liver.csv

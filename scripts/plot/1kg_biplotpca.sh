#!/bin/sh
#PBS -W group_list=cu_10039 -A cu_10039
### set erorr and output files
#PBS -e /home/projects/cu_10039/people/bartho/warfarin/sh/log/1kg.e
#PBS -o /home/projects/cu_10039/people/bartho/warfarin/sh/log/1kg.o
###set name of the job
#PBS -N 1kg
### set number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=4,mem=8gb,walltime=10:00:00
###send an email when the job is done or fails
#PBS -m ae -M barbarathorslund@hotmail.com

module load tools
module load ngs
module load plink2/1.90beta5.4
module load gcc
module load intel/perflibs
module load R/4.0.3

path=/home/projects/cu_10039/people/bartho/1KG/warf_biplot

# Annotate UKB as chr:bp:A1:A2 and get list of common snp
Rscript "1kg_commonsnp.R"

# Update marker names in bfile for ukb
plink --bfile $path/../../warfarin/data/ukb/genotype/modelSNP --update-name $path/warf_ukb_newnames.txt --make-bed --out $path/warf_ukb

# Extract common markers for both sources
plink --bfile $path/warf_ukb --extract $path/warf_ukb_common_snp.txt --make-bed --out $path/warf_ukb_common

plink --bfile $path/../Merge --extract $path/warf_ukb_common_snp.txt --make-bed --out $path/warf_1kg_common

# Merge the two
echo 'warf_ukb_common' > $path/merge_list.txt
echo 'warf_1kg_common' >> $path/merge_list.txt

cd $path

plink --merge-list merge_list.txt --make-bed --out warf_ukb_1kg_merged

# Caluclate PCA of merged data
plink --bfile warf_ukb_1kg_merge

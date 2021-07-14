#!/bin/sh
### set error and output files
#PBS -e /home/projects/cu_10039/people/bartho/warfarin/sh/log/ANN_merge.e
#PBS -o /home/projects/cu_10039/people/bartho/warfarin/sh/log/ANN_merge.o
### set name of the job
#PBS -N ANN_merge
### set number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=4,mem=8gb,walltime=2:00:00
### Send an email when the job is done
### PBS -m ae -M barbarathorslund@hotmail.com

#Prepare files using plink
module load tools
module load ngs
module load plink2/1.90beta5.4

path=/home/projects/cu_10039/people/bartho/warfarin/data/ukb/ANN/meta_sig

cd $path

# Combine typed and imputed
echo 'extract_typed' > merge_list.txt
echo 'extract_imp_chr10' >> merge_list.txt
echo 'extract_imp_chr16' >> merge_list.txt
echo 'extract_imp_chr19' >> merge_list.txt

plink --merge-list merge_list.txt --make-bed --out extract_merged

# To PED
plink --bfile extract_merged --tab --recode --out extract_merged --noweb

# To raw file, additive mode
plink --noweb --bfile extract_merged --recodeA --out extract_merged

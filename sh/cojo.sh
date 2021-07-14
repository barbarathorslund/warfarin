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

module load ngs
module load tools
module load gcta/1.26.0

COJO_OUTPUT_PATH=$1
CHR=$2

cd "${COJO_OUTPUT_PATH}" #/home/projects/cu_10039/people/bartho/warfarin/data/cojo

gcta64 --bfile /home/projects/cu_10039/people/s182542/data/databases/UKBB_peds/ukkBB_ref_chr"${CHR}" --chr "${CHR}" --maf 0.01 --cojo-file meta_warf_sumstat_cojo.txt --cojo-slct --out test_chr"${CHR}"


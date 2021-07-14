#!/bin/sh
### set erorr and output files
#PBS -r /home/projects/cu_10039/people/bartho/warfarin/sh/log/06_king.e
#PBS -o /home/projects/cu_10039/people/bartho/warfarin/sh/log/06_king.o
###set name of the job
#PBS -N king
### ser number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=20,mem=75gb,walltime=10:00:00
###send an email when the job is done
### PBS -m ae -M your.email

module load tools
module load ngs
module load king/2.1.3

KING_OUTPUT_PATH=$1
GENOTYPE_SUBSAMPLE_BED=$2

cd "${KING_OUTPUT_PATH}"
king -b "${GENOTYPE_SUBSAMPLE_BED}" --kinship --degree 3 | tee king_kingship.log

#Go back to king.R script to indentify individuals to be excluded

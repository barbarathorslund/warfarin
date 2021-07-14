#!/bin/sh
### set error and output files
#PBS -e /home/projects/cu_10039/people/bartho/warfarin/sh/log/07_king_related_pairs.e
#PBS -o /home/projects/cu_10039/people/bartho/warfarin/sh/log/07_king_related_pairs.o
### set name of the job
#PBS -N 7_king_related_pairs
### set number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=2,mem=10gb,walltime=00:30:00

module load tools
module load ngs
module load gcc
module load intel/perflibs
module load R/4.0.3

export KING_KIN_FILE=$1
export KING_KIN0_FILE=$2
export EXCLUDE_RELATED=$3

cd /home/projects/cu_10039/people/bartho/warfarin/R
Rscript "Rscripts/07_king_relatedpairs.R"

#!/bin/sh
### set error and output files
#PBS -e /home/projects/cu_10039/people/bartho/warfarin/sh/log/03_filter_qc.e
#PBS -o /home/projects/cu_10039/people/bartho/warfarin/sh/log/03_filter_qc.o
### set name of the job
#PBS -N 03_filter_qc
### set number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=2,mem=10gb,walltime=00:30:00

module load tools
module load ngs
module load gcc
module load intel/perflibs
module load R/4.0.3

export SQC_FILE_RAW=$1
export HDR_FILE_RAW=$2
export FAM_FILE_RAW=$3
export GQC_FILE_RAW=$4
export METADATA_FILE_RAW=$5
export QC_FILTERED=$6
export QC_FILTER_INFO=$7

cd /home/projects/cu_10039/people/bartho/warfarin/scripts/association_testing
Rscript "QC_filter.R"
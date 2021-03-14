#!/bin/sh
### set erorr and output files
###PBS -r king.e
###PBS -o king.o
###set name of the job
#PBS -N king
### ser number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=20,mem=75gb,walltime=10:00:00
###send an email when the job is done
### PBS -m ae -M your.email

module load king/2.1.3

cd ../data/king

king -b unimputed_king.bed --kinship --degree 3 | tee king_kingship.log

#Go back to king.R script to indentify individuals to be excluded

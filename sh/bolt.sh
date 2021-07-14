#!/bin/sh
### set erorr and output files
###PBS -r log/bolt.e
###PBS -o log/bolt.o
###set name of the job
#PBS -N bolt
### ser number of nodes, cores, memory and time
#PBS -l nodes=1:ppn=21,mem=136gb,walltime=36:00:00
###send an email when the job is done
### PBS -m ae -M barbarathorslund@hotmail.com

module load ngs
module load tools
module load intel/perflibs/64/2019_update3
module load gcc/8.2.0
module load R/3.6.1
module load tabix/1.2.1
module load bolt-lmm/2.3.4

N=$1
datapath=../data/ukb

bolt \
--bed=$datapath/genotype/modelSNP.bed \
--bim=$datapath/genotype/modelSNP.bim \
--fam=$datapath/genotype/modelSNP.fam \
--phenoFile=$datapath/Rinter/pheno.txt \
--phenoCol=logDose \
--covarFile=$datapath/Rinter/cov.txt \
--qCovarCol=yob \
--qCovarCol=PC{1:10} \
--covarCol=sex \
--covarCol=genotyping.array \
--qCovarCol=assessCenter \
--covarMaxLevels=25 \
--lmm \
--LDscoresFile=/services/tools/bolt-lmm/2.3.2/tables/LDSCORE.1000G_EUR.tab.gz \
--LDscoresMatchBp \
--geneticMapFile=/services/tools/bolt-lmm/2.3.2/tables/genetic_map_hg19_withX.txt.gz \
--numThreads=23 \
--statsFile=$datapath/bolt_out/chr${N}.stats.gz \
--bgenMinMAF=0.01 \
--bgenMinINFO=0.7 \
--verboseStats \
--noBgenIDcheck \
--statsFileBgenSnps=$datapath/bolt_out/chr${N}.bgen.stats.gz \
--bgenFile=/home/projects/cu_10039/data/UKBB/downloadDump/EGAD00010001474/ukb_imp_chr${N}_v3.bgen \
--sampleFile=$datapath/raw/saigeSampleFile.txt

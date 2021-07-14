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
module load bcftools/1.12

# Adapted from https://www.biostars.org/p/335605/

cd /home/projects/cu_10039/people/bartho/1KG

# Download VCF files

prefix="ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr" ;

suffix=".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz" ;

for chr in {1..22}; do
    wget "${prefix}""${chr}""${suffix}" "${prefix}""${chr}""${suffix}".tbi ;
done

# Download PED file
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20130606_sample_info/20130606_g1k.ped ;

# Download hg19 reference genome
wget http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/human_g1k_v37.fasta.gz ;

wget http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/human_g1k_v37.fasta.fai ;

gunzip human_g1k_v37.fasta.gz ;

# Convert to BCF
for chr in {1..22}; do
    bcftools norm -m-any --check-ref w -f human_g1k_v37.fasta \
      ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz | \
      bcftools annotate -x ID -I +'%CHROM:%POS:%REF:%ALT' | \
        bcftools norm -Ob --rm-dup both \
          > ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.bcf ;

    bcftools index ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.bcf ;
done

# Convert to PLINK format
for chr in {1..22}; do
    plink --noweb \
      --bcf ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.bcf \
      --keep-allele-order \
      --vcf-idspace-to _ \
      --const-fid \
      --allow-extra-chr 0 \
      --split-x b37 no-fail \
      --make-bed \
      --out ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes ;
done

# Filter and prune variants
mkdir Pruned ;

for chr in {1..22}; do
    plink --noweb \
      --bfile ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes \
      --maf 0.10 --indep 50 5 1.5 \
      --out Pruned/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes ;

    plink --noweb \
      --bfile ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes \
      --extract Pruned/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.prune.in \
      --make-bed \
      --out Pruned/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes ;
done

# Merge into one PLINK file

find . -name "*.bim" | grep -e "Pruned" > ForMerge.list ;

sed -i 's/.bim//g' ForMerge.list ;

plink --merge-list ForMerge.list --out Merge ;



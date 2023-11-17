#!/usr/bin/env bash
# align_workflow.sh


# get the RNA-seq paired end reads from NCBI using SRR number and fetch with SRA tootlkit fastq-dump function
fastq-dump --gzip --split-files SRR23112557 1>SRR23112557.log 2>SRR23112557.err &


# checking the quality of the reads with fastqc
fastqc SRR23112557_1.fastq.gz SRR23112557_2.fastq.gz -o fastqc_out/



# trimming the adptor sequences and incorrect base calls and low quality reads with trimmomatic

java -jar ~/Downloads/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 1 -phred33 \
SRR23112557_1.fastq.gz SRR23112557_2.fastq.gz \
SRR23112557_1_paired.fastq.gz SRR23112557_1_unpaired.fastq.gz \
SRR23112557_2_paired.fastq.gz SRR23112557_2_unpaired.fastq.gz \
ILLUMINACLIP:/home/teena/Downloads/Trimmomatic-0.39/adapters/allAdapter.fas2:2:30:10 \
SLIDINGWINDOW:5:30 \
HEADCROP:0 \
LEADING:10 \
TRAILING:10 \
MINLEN:75




# running fastqc again to check the change in quality
fastqc SRR23112557_1_paired.fastq.gz SRR23112557_2_paired.fastq.gz -o fastqc_t_out/



# building index using STAR for alignment
STAR --runMode genomeGenerate --genomeDir /home/dodeja.t/RNA_seq/analyze_data/ref/ --genomeFastaFiles /home/dodeja.t/RNA_seq/analyze_data/ref/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa --sjdbGTFfile /home/dodeja.t/RNA_seq/analyze_data/ref/Homo_sapiens.GRCh38.110.gtf --runThreadN 4


# aligning reads using reference index with STAR
STAR --runMode alignReads --genomeDir /home/dodeja.t/RNA_seq/analyze_data/ref/ --outSAMtype BAM SortedByCoordinate --readFilesIn SRR23112557_1_paired.fastq.gz SRR23112557_2_paired.fastq.gz --readFilesCommand gunzip -c  --runThreadN 4  



# creating count matrix using featureCounts from subread package using GTF file
featureCounts -a /home/teena/Documents/coursera_rna_seq/bulk\ rna\ seq/ref/Homo_sapiens.GRCh38.110.gtf -o count.out -T 2 Aligned.sortedByCoord.out.bam


# 1. Rename
# Sequencing_ID_L001
# eg. 1_S1_L001

# 2. rename
# Sample_ID


# 3. rename project_folder
# /project_folder/
# eg. /data/username/Project_A/

# 4. Make project organisation folders
mkdir /project_folder/ && \
mkdir /project_folder/1.fastq/ && \
# correct for fastq location
mkdir /project_folder/2.trim/ && \
mkdir /project_folder/3.sort/ && \
mkdir /project_folder/4.dedup/ && \
mkdir /project_folder/5.realtar/ && \
mkdir /project_folder/6.indelrealn/ && \
mkdir /project_folder/7.baserecal/ && \
mkdir /project_folder/9.printbam/ && \
mkdir /project_folder/10.gvcf/


#!/bin/bash
# 1 Cut adaptors and run FastQC
trim_galore -q 20 --fastqc_args "--outdir /project_folder/2.trim/QC_reports" --illumina --gzip \
-o /project_folder/2.trim/ -length 20 --paired \
/project_folder/1.fastq/Sequencing_ID_L001_R1_001.fastq.gz \
/project_folder/1.fastq/Sequencing_ID_L001_R2_001.fastq.gz && \

# 2 align with bwa
bwa mem -t 12 -M /home/ref/b37/human_g1k_v37.fasta \
/project_folder/2.trim/Sequencing_ID_L001_R1_001_val_1.fq.gz \
/project_folder/2.trim/Sequencing_ID_L001_R2_001_val_2.fq.gz \
-v 1 -R '@RG\tID:Sample_ID\tSM:Sample_ID_SM\tPL:ILLUMINA\tLB:Sample_ID_exome' \
-M | samtools view -Sb - > /project_folder/2.trim/Sample_ID.bam && \

# 3 sort
java -Xmx8g -jar /home/picard/picard-tools-2.5.0/picard.jar SortSam \
I=/project_folder/2.trim/Sample_ID.bam \
O=/project_folder/3.sort/Sample_ID.sort.bam \
SO=coordinate CREATE_INDEX=TRUE && \

# 4 mark duplicates
java -Xmx8g -jar /home/picard/picard-tools-2.5.0/picard.jar MarkDuplicates \
I=/project_folder/3.sort/Sample_ID.sort.bam \
O=/project_folder/4.dedup/Sample_ID.sort.dedup.bam \
M=/project_folder/4.dedup/Sample_ID.sort.dedup.metrics CREATE_INDEX=TRUE && \

# 5 Create indel realigner targets
java -Xmx6g -jar /home/GATK/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar \
-T RealignerTargetCreator \
-R /home/ref/b37/human_g1k_v37.fasta \
-known /home/ref/b37/1000G_phase1.indels.b37.vcf \
-known /home/ref/b37/Mills_and_1000G_gold_standard.indels.b37.sites.vcf \
-I /project_folder/4.dedup/Sample_ID.sort.dedup.bam \
-o /project_folder/5.realtar/Sample_ID.sort.dedup.bam.intervals && \

# 6 IndelRealigner
java -Xmx6g -jar /home/GATK/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar \
-T IndelRealigner \
-R /home/ref/b37/human_g1k_v37.fasta \
-known /home/ref/b37/1000G_phase1.indels.b37.vcf \
-known /home/ref/b37/Mills_and_1000G_gold_standard.indels.b37.sites.vcf \
-I /project_folder/4.dedup/Sample_ID.sort.dedup.bam \
-targetIntervals /project_folder/5.realtar/Sample_ID.sort.dedup.bam.intervals \
-o /project_folder/6.indelrealn/Sample_ID.sort.dedup.indelrealn.bam && \

# 7 Recalibrate Base Quality Scores (GATK) Get Recalibration Model
java -Xmx8g -jar /home/GATK/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar \
-T BaseRecalibrator \
-R /home/ref/b37/human_g1k_v37.fasta \
-knownSites /home/ref/b37/dbSnp146.b37.vcf.gz \
-knownSites /home/ref/b37/1000G_phase1.indels.b37.vcf \
-knownSites /home/ref/b37/Mills_and_1000G_gold_standard.indels.b37.sites.vcf \
-o /project_folder/7.baserecal/Sample_ID.sort.dedup.indelrealn.recal.grp \
-I /project_folder/6.indelrealn/Sample_ID.sort.dedup.indelrealn.bam \
-nct 6 && \

# 8 optional check for base recal

# 9 Print final reads after applying BQSR
java -Xmx12g -jar /home/GATK/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar \
-T PrintReads \
-R /home/ref/b37/human_g1k_v37.fasta \
-I /project_folder/6.indelrealn/Sample_ID.sort.dedup.indelrealn.bam \
-BQSR /project_folder/7.baserecal/Sample_ID.sort.dedup.indelrealn.recal.grp \
-o /project_folder/9.printbam/Sample_ID.sort.dedup.indelrealn.recal.bam \
--disable_indel_quals && \

# 10 HC
java -Xmx8g -jar /home/GATK/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar \
-T HaplotypeCaller --emitRefConfidence GVCF \
-R /home/ref/b37/human_g1k_v37.fasta -D /home/ref/b37/dbSnp146.b37.vcf.gz \
-stand_call_conf 30 -stand_emit_conf 10 \
-I /project_folder/9.printbam/Sample_ID.sort.dedup.indelrealn.recal.bam \
-o /project_folder/10.gvcf/Sample_ID.sort.dedup.indelrealn.recal.HC.g.vcf \
-L /home/ref/SureSelectAllExonV6/S07604514_Regions_b37.bed -ip 30 && \

exit

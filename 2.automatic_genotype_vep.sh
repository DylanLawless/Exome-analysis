
# Do not forget to create directory
mkdir /project_folder/geno/

#!/bin/bash
# 11 Joint genotype
java -Xmx12g -jar /home/GATK/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar \
-T GenotypeGVCFs \
-R /home/ref/b37/human_g1k_v37.fasta \
-D /home/ref/b37/dbSnp146.b37.vcf.gz -stand_call_conf 30 \
-stand_emit_conf 10 \
-V /project_folder/10.gvcf/Sample_ID.sort.dedup.indelrealn.recal.HC.g.vcf \
-V /project_folder/10.gvcf/Sample_ID.sort.dedup.indelrealn.recal.HC.g.vcf \
-V /project_folder/10.gvcf/Sample_ID.sort.dedup.indelrealn.recal.HC.g.vcf \
-V /project_folder/10.gvcf/Sample_ID.sort.dedup.indelrealn.recal.HC.g.vcf \
-V /project_folder/10.gvcf/Sample_ID.sort.dedup.indelrealn.recal.HC.g.vcf \
-V /project_folder/10.gvcf/Sample_ID.sort.dedup.indelrealn.recal.HC.g.vcf \
-V /project_folder/10.gvcf/Sample_ID.sort.dedup.indelrealn.recal.HC.g.vcf \
-V /project_folder/10.gvcf/Sample_ID.sort.dedup.indelrealn.recal.HC.g.vcf \
-o /project_folder/geno/genotype.vcf -nda --showFullBamList -nt 12 && \

# 12 Hard filter
java -Xmx12g -jar /home/GATK/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar \
-T SelectVariants \
-R /home/ref/b37/human_g1k_v37.fasta \
-selectType SNP \
--variant /project_folder/geno/genotype.vcf \
-o /project_folder/geno/genotype.raw-snps.vcf && \

java -Xmx12g -jar /home/GATK/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar \
-T SelectVariants \
-R /home/ref/b37/human_g1k_v37.fasta \
--variant /project_folder/geno/genotype.vcf \
-selectType INDEL -selectType MNP \
-o /project_folder/geno/genotype.raw-indels.vcf && \

java -Xmx8g -jar /home/GATK/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar \
-T VariantFiltration \
-R /home/ref/b37/human_g1k_v37.fasta \
-V /project_folder/geno/genotype.raw-snps.vcf \
--filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MappingQualityRankSum < -12.5 || ReadPosRankSum < -8.0" \
--filterName "snp_hard_filter" \
-o /project_folder/geno/genotype.raw-snps.filtered.snvs.vcf && \

java -Xmx8g -jar /home/GATK/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar \
-T VariantFiltration \
-R /home/ref/b37/human_g1k_v37.fasta \
-V /project_folder/geno/genotype.raw-indels.vcf \
--filterExpression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0" \
--filterName "indel_hard_filter" \
-o /project_folder/geno/genotype.raw-indels.filtered.indels.vcf && \

java -Xmx8g -jar /home/GATK/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar \
-T CombineVariants -R /home/ref/b37/human_g1k_v37.fasta \
--variant /project_folder/geno/genotype.raw-snps.filtered.snvs.vcf \
--variant /project_folder/geno/genotype.raw-indels.filtered.indels.vcf \
-o /project_folder/geno/genotype.fltd-combinedvars.vcf \
--genotypemergeoption UNSORTED && \


# 16 filter variants in EdbSNP >/= 1% and not listed as pothogenic by ClinVar
perl /home/vcfhacks-v0.2.0/annotateSnps.pl \
-d /home/ref/b37/dbSnp146.b37.vcf.gz /home/ref/b37/clinvar_20160531.vcf.gz -f 1 -pathogenic \
-i /project_folder/geno/genotype.fltd-combinedvars.vcf \
-o /project_folder/geno/genotype.fltd-combinedvars.1pcdbsnp.vcf -t 12 && \

# 17 filter variants in EVS greater >/= 1%
perl /home/vcfhacks-v0.2.0/filterOnEvsMaf.pl -d /home/ref/evs/ -f 1 --progress \
-i /project_folder/geno/genotype.fltd-combinedvars.1pcdbsnp.vcf \
-o /project_folder/geno/genotype.fltd-combinedvars.1pcdbsnp.1pcEVS.vcf -t 12 && \

#19 Exac filter
ExAC
perl /home/vcfhacks-v0.2.0/filterVcfOnVcf.pl \
-i /data/medddz/AnnotatedbSNP/combined.0.01.filtered.combinedvar.1pcdbsnp.vcf \
-f /home/ref/ExAC/ExAC.r0.3.sites.vep.vcf.gz \
-o /data/medddz/ExAC/combined.0.01.filtered.combinedvar.1pcdbsnp.exac.vcf -w -y 0.01
-b
# progress bar
-t
# fork

&& \



# 20 annotate with vep
perl /home/variant_effect_predictor/variant_effect_predictor.pl \
--offline --vcf --everything \
--dir_cache /home/variant_effect_predictor/vep_cache \
--dir_plugins /home/variant_effect_predictor/vep_cache/Plugins \
--plugin Condel,/home/variant_effect_predictor/vep_cache/Plugins/config/Condel/config/ \
--plugin ExAC,/home/ref/ExAC/ExAC.r0.3.sites.vep.vcf.gz \
--plugin SpliceConsensus \
--fasta /home/variant_effect_predictor/fasta/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz \
-i /project_folder/geno/genotype.fltd-combinedvars.1pcdbsnp.1pcEVS.vcf \
-o /project_folder/geno/genotype.fltd-combinedvars.1pcdbsnp.1pcEVS.vep.vcf \
--fork 12 && \

#getSamplesname
perl /home/vcfhacks-v0.2.0/getSampleNames.pl \
-i /project_folder/geno/genotype.fltd-combinedvars.1pcdbsnp.1pcEVS.vep.vcf && \

exit

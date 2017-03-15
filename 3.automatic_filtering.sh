# Your important working file:
# /project_folder/geno/genotype.fltd-combinedvars.1pcdbsnp.1pcEVS.exac.vep.vcf

# rename
# Sample_ID

#!/bin/bash

# Do not forget to create directory
mkdir /project_folder/filtered/

# Filter On Sample is key.. READ the manual
# /home/vcfhacks-v0.2.0/filterOnSample.pl --man

# 19 filter on sample
perl /home/vcfhacks-v0.2.0/filterOnSample.pl \
-i /project_folder/geno/genotype.fltd-combinedvars.1pcdbsnp.1pcEVS.exac.vep.vcf  \
-s Sample_ID_SM -x \
-o /project_folder/filtered/Sample_ID.vcf && \

# 21 getFunctionalVariantsVep
perl /home/vcfhacks-v0.2.0/getFunctionalVariants.pl \
-i /project_folder/filtered/Sample_ID.vcf \
-s Sample_ID_SM \
-o /project_folder/filtered/Sample_ID.getFunctionalVariantsVep.vcf && \

perl /home/vcfhacks-v0.2.0/rankOnCaddScore.pl \
-c /data/shared/cadd/v1.2/*.gz \
-i /project_folder/filtered/Sample_ID.getFunctionalVariantsVep.vcf \
-o /project_folder/filtered/Sample_ID.getFunctionalVariantsVep.cadd_ranked.vcf --progress && \

perl /home/vcfhacks-v0.2.0/geneAnnotator.pl \
-d /home/vcfhacks-v0.2.0/data/geneAnnotatorDb \
-i /project_folder/filtered/Sample_ID.getFunctionalVariantsVep.cadd_ranked.vcf \
-o /project_folder/filtered/Sample_ID.getFunctionalVariantsVep.cadd_ranked.gene_anno && \

perl /home/vcfhacks-v0.2.0/annovcfToSimple.pl \
-i /project_folder/filtered/Sample_ID.getFunctionalVariantsVep.cadd_ranked.gene_anno \
--vep --gene_anno \
-o /project_folder/filtered/Sample_ID.getFunctionalVariantsVep.cadd_ranked.gene_anno.simple.xlsx && \

# 21 findBiallelic
perl /home/vcfhacks-v0.2.0/findBiallelic.pl \
-i /project_folder/filtered/Sample_ID.vcf  \
-s Sample_ID_SM -x \
-o /project_folder/filtered/Sample_ID.findBiallelic.vcf && \

perl /home/vcfhacks-v0.2.0/rankOnCaddScore.pl \
-c /data/shared/cadd/v1.2/*.gz \
-i /project_folder/filtered/Sample_ID.findBiallelic.vcf \
-o /project_folder/filtered/Sample_ID.findBiallelic.cadd_ranked.vcf -n cadd_not_found.tvs --progress && \

perl /home/vcfhacks-v0.2.0/geneAnnotator.pl \
-d /home/vcfhacks-v0.2.0/data/geneAnnotatorDb \
-i /project_folder/filtered/Sample_ID.findBiallelic.cadd_ranked.vcf \
-o /project_folder/filtered/Sample_ID.findBiallelic.cadd_ranked.gene_anno && \

perl /home/vcfhacks-v0.2.0/annovcfToSimple.pl \
-i /project_folder/filtered/Sample_ID.findBiallelic.cadd_ranked.gene_anno \
--vep --gene_anno \
-o /project_folder/filtered/Sample_ID.findBiallelic.cadd_ranked.gene_anno.simple.xlsx && \

# 21 getHetVariants
perl /home/vcfhacks-v0.2.0/getHetVariants.pl \
-i /project_folder/filtered/Sample_ID.vcf \
-s Sample_ID_SM \
-r \
-o /project_folder/filtered/Sample_ID.getHetVariants.Hom.vcf && \

perl /home/vcfhacks-v0.2.0/rankOnCaddScore.pl \
-c /data/shared/cadd/v1.2/*.gz \
-i /project_folder/filtered/Sample_ID.getHetVariants.Hom.vcf \
-o /project_folder/filtered/Sample_ID.getHetVariants.Hom.cadd_ranked.vcf -n cadd_not_found.tvs --progress && \

perl /home/vcfhacks-v0.2.0/geneAnnotator.pl \
-d /home/vcfhacks-v0.2.0/data/geneAnnotatorDb \
-i /project_folder/filtered/Sample_ID.getHetVariants.Hom.cadd_ranked.vcf \
-o /project_folder/filtered/Sample_ID.getHetVariants.Hom.cadd_ranked.gene_anno && \

perl /home/vcfhacks-v0.2.0/annovcfToSimple.pl \
-i /project_folder/filtered/Sample_ID.getHetVariants.Hom.cadd_ranked.gene_anno \
--vep --gene_anno \
-o /project_folder/filtered/Sample_ID.getHetVariants.Hom.cadd_ranked.gene_anno.simple.xlsx && \

exit

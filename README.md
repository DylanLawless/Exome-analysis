# Exome-analysis

Setting up automated processing of fastq files from WES

I will continue to add to this to require only a single input.
This input will be a list of file names and paths to fastqs. 

I also plan to have options for filtering methods, ie. pedigree input file and filtering strategy. 
Currently it can be used to filter each sample against all others in a joint genotyped vcf or lone genotyping and produces output for:
  - functional variants (dominant diseases).
  - Bialleic variants.
  - Homozygous varaints. 

A batch process will also be added to simplify grouping.

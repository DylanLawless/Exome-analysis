# Exome-analysis

Setting up automated processing of fastq files from WES

I will continue to add to this to require only a single input.
This input will be a list of file names and paths to fastqs. 

I will also plan to have options for filtering methods, ie. pedigree input file and filtering strategy. 
Currently it just filters each sample against all others in a joint genotyped vcf and produces output for:
  - functional variants.
  - Bialleic variants.
  - Homozygous varaints. 


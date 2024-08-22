# snpeffToMaf
SnpEff is more tiny than VEP, and more HGVS than ANNOVAR  
e.g, ```java -jar snpEff.jar hg19 yourSampleName.normalize.vcf -hgvs1LetterAa -canon > yourSampleName.snpeff.vcf```  
  
🔥 support complex variants(greater than one base)


## a test environment  
* samtools 1.9 and bcftools 1.6
* SnpEff 4.3t 
* R 3.6.3  

## usage example 
1. in shell  
```perl snpeffToMaf.pl yourSampleName.snpeff.vcf 100 0.05```  
*100* for minimum depth *0.05* for minimum allele frequency  
***warn: you may need reformat with GT:DP:AD if vcf created by other variant callers. https://samtools.github.io/bcftools/howtos/query.html + https://samtools.github.io/bcftools/bcftools.html#expressions***

2. in shell  
```cat *maf | awk '!/Hugo_Symbol/ || NR==1' > all.maf```  
concatenate all of **yourSampleName.maf**, but not necessary  

3. in R  
```library(maftools)```  
```syn <- c("synonymous_variant","start_retained","stop_retained_variant")```  
```df <- data.table::fread("all.maf")```  
```vc <- names(table(df$Variant_Classification))```  
```nonSyn <- setdiff(vc,syn)```  
```colors <- rainbow(length(nonSyn))```  
```names(colors) <- nonSyn```  
```maf <- read.maf("all.maf", vc_nonSyn = nonSyn)```  
```plotmafSummary(maf, rmOutlier = TRUE, addStat = 'median', dashboard = TRUE, titvRaw = FALSE, color = colors)```  

## screenshot
![img](https://github.com/tsy19900929/snpeffToMaf/blob/master/plotmafSummary.png)

## issues
![img](https://github.com/tsy19900929/snpeffToMaf/blob/master/issues.png)

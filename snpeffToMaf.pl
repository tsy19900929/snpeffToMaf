#!/usr/bin/perl

use strict;
use warnings;

my $snpeff;
my @line;
my $DP;
my $AD;
my $minDP;
my $minAF;
my $maf;

my $Hugo_Symbol;
my $Entrez_Gene_Id;
my $Center;
my $NCBI_Build;
my $Chromosome;
my $Start_Position;
my $End_Position;
my $Strand;
my $Variant_Classification;
my $Variant_Type;
my $Reference_Allele;
my $Tumor_Seq_Allele1;
my $Tumor_Seq_Allele2;
my $Tumor_Sample_Barcode;
my $Protein_Change;
my $i_TumorVAF_WU;
my $i_transcript_name;

$snpeff = shift;
$minDP = shift;
$minAF = shift;

($Entrez_Gene_Id,$Center,$NCBI_Build,$Strand)=("NA","NA",37,"NA");
$Tumor_Sample_Barcode = (split /\./,$snpeff)[0];
$maf = $Tumor_Sample_Barcode.".maf";

open INFILE,"$snpeff" or die;
open OUTFILE,">$maf" or die;

print OUTFILE "Hugo_Symbol\tEntrez_Gene_Id\tCenter\tNCBI_Build\tChromosome\tStart_Position\tEnd_Position\tStrand\tVariant_Classification\tVariant_Type\tReference_Allele\tTumor_Seq_Allele1\tTumor_Seq_Allele2\tTumor_Sample_Barcode\tProtein_Change\ti_TumorVAF_WU\ti_transcript_name\n";

while(<INFILE>){
    next if /^#/;
    chomp;
    @line = split /\t/;
    next if $line[4] eq '.';
    $DP = (split /:/,$line[-1])[-2];
    next if $DP < $minDP;
    $AD = (split /,/,$line[-1])[-1];
    $i_TumorVAF_WU = $AD/$DP;
    next if $i_TumorVAF_WU < $minAF;
    $i_TumorVAF_WU=sprintf "%0.5f",$i_TumorVAF_WU;

    ($Chromosome,$Start_Position,$Reference_Allele,$Tumor_Seq_Allele2) = @line[0,1,3,4];
    $Chromosome =~ s/chr//;
    if ((length($Reference_Allele) == 1) && (length($Tumor_Seq_Allele2) == 1)){
        $End_Position = $Start_Position;
        $Variant_Type ="SNP";
    }elsif ((length($Reference_Allele) >1) && (length($Tumor_Seq_Allele2) == 1)){
        $Start_Position += 1;
        $Reference_Allele = substr($Reference_Allele,1);
        $Tumor_Seq_Allele2 = '-';
        $End_Position = $Start_Position + length($Reference_Allele) - 1;
        $Variant_Type ="DEL";
    }elsif ((length($Reference_Allele) ==1 ) && (length($Tumor_Seq_Allele2) > 1)){
        $End_Position = $Start_Position + 1;
        $Reference_Allele = '-';
        $Tumor_Seq_Allele2 = substr($Tumor_Seq_Allele2,1);
        $Variant_Type ="INS";
    };
    $Tumor_Seq_Allele1 = $Reference_Allele;
 
    if ($line[7] =~ /(ANN=\S+)/){
        ($Variant_Classification,$Hugo_Symbol,$i_transcript_name,$Protein_Change)=(split /\|/,$1)[1,3,6,10];
        next if not $Protein_Change;
    }else{
        next;
    };
        
    print OUTFILE "$Hugo_Symbol\t$Entrez_Gene_Id\t$Center\t$NCBI_Build\t$Chromosome\t$Start_Position\t$End_Position\t$Strand\t$Variant_Classification\t$Variant_Type\t$Reference_Allele\t$Tumor_Seq_Allele1\t$Tumor_Seq_Allele2\t$Tumor_Sample_Barcode\t$Protein_Change\t$i_TumorVAF_WU\t$i_transcript_name\n";
    
};

close INFILE;
close OUTFILE;

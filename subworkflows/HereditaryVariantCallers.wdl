version 1.0
# -------------------------------------------------------------------------------------------------
# Workflow Summary: Variant callers for hereditary cancer workflows
# Tools used:
#  + FreeBayes
#  + GATK HaplotypeCallerERC
#  + GATK GenotypeGVCFs
# -------------------------------------------------------------------------------------------------

import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/freebayes/FreeBayes.wdl" as FreeBayes
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/gatk/HaplotypeCallerERC.wdl" as HaplotypeCallerERC
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/gatk/GenotypeGVCFs.wdl" as GenotypeGVCFs

workflow VariantCaller {
  input {
    # Inputs
    String sample_id
    File bam_file
    File bam_idx_file
    File gvcf_file
    File gvcf_idx_file
    File intervals
    # Tools
    File ? java
    File ? freebayes
    File ? dbsnp
    File ? dbsnp_idx
    File ? gatk
    # References
    File reference
    File reference_idx
    File reference_dict
  }

  call FreeBayes.FreeBayes {
    input:
      freebayes=freebayes,
      reference=reference,
      reference_idx=reference_idx,
      intervals=intervals,
      sample_id=sample_id,
      bam_file=bam_file,
      bam_idx_file=bam_idx_file,
  }

  call HaplotypeCallerERC.HaplotypeCallerERC {
    input:
      sample_id=sample_id,
      bam_file=bam_file,
      bam_idx_file=bam_idx_file,
      java=java,
      gatk=gatk,
      reference=reference,
      reference_idx=reference_idx,
      reference_dict=reference_dict,
      intervals=[intervals],
      dbsnp=dbsnp,
      dbsnp_idx=dbsnp_idx,
  }

  call GenotypeGVCFs.GenotypeGVCFs {
    input:
      cohort_id=sample_id,
      gvcf_files=[gvcf_file],
      gvcf_idx_files=[gvcf_idx_file],
      intervals=[intervals],
      java=java,
      gatk=gatk,
      reference=reference,
      reference_idx=reference_idx,
      reference_dict=reference_dict,
      dbsnp=dbsnp,
      dbsnp_idx=dbsnp_idx,
  }

  output {
    File freebayes_vcf_file = FreeBayes.vcf_file
    File haplotypecaller_gvcf_file =HaplotypeCallerERC.gvcf_file
    File haplotypecaller_gvcf_idx_file =HaplotypeCallerERC.gvcf_idx_file
    File genotypegvcf_vcf_file =GenotypeGVCFs.vcf_file
    File genotypegvcf_vcf_idx_file =GenotypeGVCFs.vcf_idx_file
  }

  parameter_meta {
    sample_id: "prefix for output files."
    bam_file: "Sorted and duplicate marked BAM file."
    bam_idx_file: "BAM file index (.bai)."
    gvcf_file: "gVCF file"
    gvcf_idx_file: "gVCF index file (.tbi)."
    intervals: "One or more genomic intervals over which to operate (Should be in BED format)."
    java: "Path to Java."
    gatk: "Path to gatk."
    freebayes: "FreeBayes executable."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    reference_dict: "Reference sequence dict (.dict)."
    dbsnp: "dbSNP VCF file."
    dbsnp_idx: "dbSNP VCF index file (.tbi)."
  }

  meta {
    author: "Tolga Ayazseven"
    email: "ayazsevent@email.chop.edu"
    version: "0.1.0"
  }
}

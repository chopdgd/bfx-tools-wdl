version 1.0
# -------------------------------------------------------------------------------------------------
# Workflow Summary: Variant callers for germline cancer workflows
# Tools used:
#  + FreeBayes
#  + GATK HaplotypeCaller + GenotypeGVCFs
# -------------------------------------------------------------------------------------------------

import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/freebayes/FreeBayes.wdl" as FreeBayes
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/gatk/HaplotypeCallerERC.wdl" as HaplotypeCaller
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/gatk/GenotypeGVCFs.wdl" as GenotypeGVCFs

workflow VariantCaller {
  input {
    String sample_id
    File bam_file
    File bam_idx_file

    File intervals  # NOTE: This should be in BED format, so all tools could use

    File ? java
    File ? freebayes
    File ? gatk

    File reference
    File reference_idx
    File reference_dict

    File ? dbsnp
    File ? dbsnp_idx
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

  call HaplotypeCaller.HaplotypeCallerERC {
    input:
      java=java,
      gatk=gatk,
      reference=reference,
      reference_idx=reference_idx,
      reference_dict=reference_dict,
      dbsnp=dbsnp,
      dbsnp_idx=dbsnp_idx,
      intervals=[intervals],
      sample_id=sample_id,
      bam_file=bam_file,
      bam_idx_file=bam_idx_file,
  }

  call GenotypeGVCFs.GenotypeGVCFs {
    input:
      java=java,
      gatk=gatk,
      reference=reference,
      reference_idx=reference_idx,
      reference_dict=reference_dict,
      dbsnp=dbsnp,
      dbsnp_idx=dbsnp_idx,
      intervals=[intervals],
      cohort_id=sample_id,
      gvcf_files=[HaplotypeCallerERC.gvcf_file],
      gvcf_idx_files=[HaplotypeCallerERC.gvcf_idx_file],
  }

  output {
    File freebayes_vcf_file = FreeBayes.vcf_file
    File gatk_vcf_file = GenotypeGVCFs.vcf_file
    File gatk_vcf_idx_file = GenotypeGVCFs.vcf_file
  }

  parameter_meta {
    sample_id: "prefix for output files."
    bam_file: "Sorted and duplicate marked BAM file."
    bam_idx_file: "BAM file index (.bai)."
    intervals: "One or more genomic intervals over which to operate (Should be in BED format)."
    java: "Path to Java."
    freebayes: "FreeBayes executable."
    gatk: "GATK jar file."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    reference_dict: "Reference sequence dict (.dict)."
    dbsnp: "dbSNP VCF file."
    dbsnp_idx: "dbSNP VCF index file (.tbi)."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    version: "0.1.0"
  }
}

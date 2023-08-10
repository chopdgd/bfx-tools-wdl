version 1.0
# -------------------------------------------------------------------------------------------------
# Workflow Summary: BAM to GVCF using Picard and GATK
# Tools Used:
#  * Picard MarkDuplicates
#  * GATK HaplotypeCaller in ERC mode
#  * GATK DepthOfCoverage
#  * Picard CollectHsMetrics
#  * VerifyBamId
# -------------------------------------------------------------------------------------------------
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.9.0/unix/commands.wdl" as Unix
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.4.1/picard/MarkDuplicates.wdl" as Picard
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.4.1/gatk/HaplotypeCallerERC.wdl" as GATK
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.4.1/subworkflows/BAM-Quality-Control.wdl" as BAMQualityControl

workflow BAMToGVCFAndBAMQC {
  input {
    String sample_id
    String input_bam_file # sorted.bam file from previous WES run
    String input_bam_idx_file # sorted.bam.bai from previous WES run

    File ? java
    File ? picard
    File ? gatk
    File ? verifybamid

    File reference
    File reference_idx
    File reference_dict

    File ? dbsnp
    File ? dbsnp_idx

    File bait_intervals
    File target_intervals
    File variant_calling_intervals
    Array[Int] summary_coverage_threshold
    File ? omni_vcf
    File ? omni_vcf_idx

  }


  call Picard.MarkDuplicates as MarkDuplicates {
    input:
      java=java,
      picard=picard,
      reference=reference,
      reference_idx=reference_idx,
      sample_id=sample_id,
      input_file=input_bam_file,
  }

  call GATK.HaplotypeCallerERC as HaplotypeCaller {
    input:
      java=java,
      gatk=gatk,
      reference=reference,
      reference_idx=reference_idx,
      reference_dict=reference_dict,
      dbsnp=dbsnp,
      dbsnp_idx=dbsnp_idx,
      intervals=[variant_calling_intervals],
      sample_id=sample_id,
      bam_file=MarkDuplicates.bam_file,
      bam_idx_file=MarkDuplicates.bam_idx_file,
  }

  call BAMQualityControl.BAMQualityControl {
    input:
      java=java,
      gatk=gatk,
      picard=picard,
      verifybamid=verifybamid,
      sample_id=sample_id,
      bam_file=MarkDuplicates.bam_file,
      bam_idx_file=MarkDuplicates.bam_idx_file,
      reference=reference,
      reference_idx=reference_idx,
      reference_dict=reference_dict,
      bait_intervals=bait_intervals,
      target_intervals=target_intervals,
      summary_coverage_threshold=summary_coverage_threshold,
      omni_vcf=omni_vcf,
      omni_vcf_idx=omni_vcf_idx,
  }

  output {
    # BAMs
    File bam_file = input_bam_file
    File bam_idx_file = input_bam_idx_file
    File markdups_bam_file = MarkDuplicates.bam_file
    File markdups_bam_idx_file = MarkDuplicates.bam_idx_file

    # gVCFs
    File gvcf_file = HaplotypeCaller.gvcf_file
    File gvcf_idx_file = HaplotypeCaller.gvcf_idx_file

    # QC
    # File alignment_metrics_file = Alignment.metrics_file
    File markdups_metrics_file = MarkDuplicates.metrics_file
    File sample_interval_statistics_file = BAMQualityControl.sample_interval_statistics_file
    File sample_statistics_file = BAMQualityControl.sample_statistics_file
    File sample_summary_file = BAMQualityControl.sample_summary_file
    File sample_interval_summary_file = BAMQualityControl.sample_interval_summary_file
    File hs_metrics_file = BAMQualityControl.hs_metrics_file
    File per_target_coverage_file = BAMQualityControl.per_target_coverage_file
    File ? contamination_file = BAMQualityControl.contamination_file
  }

  parameter_meta {
    sample_id: "Sample ID to use in SAM TAG."
    java: "Path to Java."
    samtools: "Samtools executable."
    picard: "Picard jar file."
    gatk: "GATK jar file."
    verifybamid: "VerifyBamId executable."
    reference: "Reference sequence fasta file."
    reference_idx: "Reference sequence index (.fai)."
    reference_dict: "Reference sequence dict (.dict)."
    dbsnp: "dbSNP VCF file."
    dbsnp_idx: "dbSNP VCF index file (.tbi)."
    bait_intervals: "An interval list file that contains the locations of the baits used. Default value: null. This option must be specified at least 1 times."
    target_intervals: "An interval list file that contains the locations of the targets. Default value: null. This option must be specified at least 1 times."
    variant_calling_intervals: "An interval list file that contains the locations of the variant calling intervals. Default value: target_intervals."
    summary_coverage_threshold: "Coverage threshold (in percent) for summarizing statistics."
    omni_vcf: "OMNI 2500 Genotypes VCF for VerifyBamId"
    omni_vcf_idx: "OMNI 2500 Genotypes VCF index for VerifyBamId"
  }

  meta {
    author: "Weixuan Fu"
    email: "fuw@chop.edu"
    version: "0.1.0"
    allowNestedInputs: true
  }
}
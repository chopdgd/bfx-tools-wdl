version 1.0
# -------------------------------------------------------------------------------------------------
# Workflow Summary: Run summary quality control tools on BAM file
# Tools Used:
#  * GATK DepthOfCoverage
#  * Picard CollectHsMetrics
#  * VerifyBamId
# -------------------------------------------------------------------------------------------------


import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/rhel9-updates/gatk/DepthOfCoverage.wdl" as DepthOfCoverage
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.4.1/picard/CollectHsMetrics.wdl" as CollectHsMetrics
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.4.1/verifybamid/VerifyBamId.wdl" as VerifyBamId

workflow BAMQualityControl {
  input {
    File ? java
    File ? gatk
    File ? picard
    File ? verifybamid

    String sample_id
    File bam_file
    File bam_idx_file

    File reference
    File reference_idx
    File reference_dict

    File bait_intervals
    File target_intervals
    Array[Int] summary_coverage_threshold
    File ? omni_vcf
    File ? omni_vcf_idx
  }

  call DepthOfCoverage.DepthOfCoverage {
    input:
      java=java,
      gatk=gatk,
      reference=reference,
      reference_idx=reference_idx,
      reference_dict=reference_dict,
      intervals=[target_intervals],
      sample_id=sample_id,
      bam_files=[bam_file],
      bam_idx_files=[bam_idx_file],
      summary_coverage_threshold=summary_coverage_threshold
  }

  call CollectHsMetrics.CollectHsMetrics {
    input:
      java=java,
      picard=picard,
      reference=reference,
      reference_idx=reference_idx,
      sample_id=sample_id,
      input_file=bam_file,
      input_idx_file=bam_idx_file,
      bait_intervals=bait_intervals,
      target_intervals=target_intervals,
  }

  if (defined(verifybamid)) {
    call VerifyBamId.VerifyBamId {
      input:
        verifybamid=select_first([verifybamid, picard]),
        sample_id=sample_id,
        bam_file=bam_file,
        bam_idx_file=bam_idx_file,
        omni_vcf=select_first([omni_vcf, picard]),
        omni_vcf_idx=select_first([omni_vcf_idx, picard]),
    }
  }

  output {
    File sample_interval_statistics_file = DepthOfCoverage.sample_interval_statistics_file
    File sample_statistics_file = DepthOfCoverage.sample_statistics_file
    File sample_summary_file = DepthOfCoverage.sample_summary_file
    File sample_interval_summary_file = DepthOfCoverage.sample_interval_summary_file
    File hs_metrics_file = CollectHsMetrics.metrics_file
    File per_target_coverage_file = CollectHsMetrics.per_target_coverage_file
    File ? contamination_file = VerifyBamId.freemix_file
  }

  parameter_meta {
    java: "Path to Java."
    gatk: "GATK jar file."
    picard: "Picard jar file."
    verifybamid: "VerifyBamId executable."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    reference_dict: "Reference sequence dict (.dict)."
    sample_id: "prefix for output files."
    bam_file: "Sorted and duplicate marked BAM file."
    bam_file_idx: "BAM file index (.bai)."
    bait_intervals: "An interval list file that contains the locations of the baits used. Default value: null. This option must be specified at least 1 times."
    target_intervals: "An interval list file that contains the locations of the targets. Default value: null. This option must be specified at least 1 times."
    summary_coverage_threshold: "Coverage threshold (in percent) for summarizing statistics."
    omni_vcf: "OMNI 2500 Genotypes VCF for VerifyBamId"
    omni_vcf_idx: "OMNI 2500 Genotypes VCF index for VerifyBamId"
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    version: "0.1.0"
  }
}

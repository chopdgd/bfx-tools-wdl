version 1.0
# -------------------------------------------------------------------------------------------------
# Workflow Summary: FASTQ to BAM pipeline using NovoAlign, Samtools, and Picard
# Tools Used:
#  * NovoAlign
#  * Samtools sort
#  * Picard MarkDuplicates
#  * GATK HaplotypeCaller in ERC mode
#  * GATK DepthOfCoverage
#  * Picard CollectHsMetrics
#  * VerifyBamId
# -------------------------------------------------------------------------------------------------

import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/rhel9-updates/utilities/CombineFastQ.wdl" as CombineFastQ
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.6.0/utilities/novoalign-select-userstring.wdl" as SelectPlatform
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.6.0/novoalign/NovoAlignAndSamtoolsSort.wdl" as NovoAlign
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.4.1/picard/MarkDuplicates.wdl" as Picard
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.4.1/gatk/HaplotypeCallerERC.wdl" as GATK
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.4.1/subworkflows/BAM-Quality-Control.wdl" as BAMQualityControl

workflow FastQToGVCFAndBAMQC {
  input {
    String sample_id
    File fastq_1
    Array[File] additional_fastq1
    File fastq_2
    Array[File] additional_fastq2
    String platform

    File ? java
    File ? novoalign
    File novoalign_license
    File ? samtools
    File ? picard
    File ? gatk
    File ? verifybamid

    File reference_novoindex
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

  call CombineFastQ.CombineFastQ as CombineRead1 {
    input:
      fastq=fastq_1,
      additional_fastq=additional_fastq1,
  }

  call CombineFastQ.CombineFastQ as CombineRead2 {
    input:
      fastq=fastq_2,
      additional_fastq=additional_fastq2,
  }

  call SelectPlatform.SelectPlatform {
    input:
      platform=platform,
  }

  call NovoAlign.NovoAlignAndSamtoolsSort as Alignment {
    input:
      novoalign=novoalign,
      novoalign_license=novoalign_license,
      samtools=samtools,
      reference_novoindex=reference_novoindex,
      userString=SelectPlatform.userString,
      reference=reference,
      reference_idx=reference_idx,
      sample_id=sample_id,
      fastq_1=CombineRead1.output_file,
      fastq_2=CombineRead2.output_file,
  }

  call Picard.MarkDuplicates as MarkDuplicates {
    input:
      java=java,
      picard=picard,
      reference=reference,
      reference_idx=reference_idx,
      sample_id=sample_id,
      input_file=Alignment.bam_file,
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
    File bam_file = Alignment.bam_file
    File bam_idx_file = Alignment.bam_idx_file
    File markdups_bam_file = MarkDuplicates.bam_file
    File markdups_bam_idx_file = MarkDuplicates.bam_idx_file

    # gVCFs
    File gvcf_file = HaplotypeCaller.gvcf_file
    File gvcf_idx_file = HaplotypeCaller.gvcf_idx_file

    # QC
    File alignment_metrics_file = Alignment.metrics_file
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
    fastq_1: "FASTQ Files left reads."
    fastq_2: "FASTQ Files right reads."
    java: "Path to Java."
    novoalign: "NovoAlign executable."
    novoalign_license: "NovoAlign License."
    samtools: "Samtools executable."
    picard: "Picard jar file."
    gatk: "GATK jar file."
    verifybamid: "VerifyBamId executable."
    reference: "Reference sequence fasta file."
    reference_novoindex: "Reference sequence file index with NovoIndex."
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
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    version: "0.1.0"
  }
}
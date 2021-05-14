version 1.0
# -------------------------------------------------------------------------------------------------
# Workflow Summary: FASTQ to BAM pipeline using NovoAlign, Samtools, and Picard
# Tools Used:
#  * NovoAlign
#  * Samtools sort
#  * Picard MarkDuplicates
# -------------------------------------------------------------------------------------------------

import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.4.1/utilities/CombineFastQ.wdl" as CombineFastQ
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.6.0/utilities/novoalign-select-userstring.wdl" as SelectPlatform
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.6.0/novoalign/NovoAlignAndSamtoolsSort.wdl" as NovoAlign
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.4.1/picard/MarkDuplicates.wdl" as Picard
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.4.1/subworkflows/BAM-Quality-Control.wdl" as BAMQualityControl

workflow FastQToBAM {
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
      reference=reference,
      reference_idx=reference_idx,
      sample_id=sample_id,
      userString=SelectPlatform.userString,
      fastq_1=CombineRead1.output_file,
      fastq_2=CombineRead2.output_file,
  }

  call Picard.MarkDuplicates as MarkDuplicates {
    input:
      picard=picard,
      reference=reference,
      reference_idx=reference_idx,
      sample_id=sample_id,
      input_file=Alignment.bam_file,
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
    novoalign: "NovoAlign executable."
    novoalign_license: "NovoAlign License."
    samtools: "Samtools executable."
    picard: "Picard jar file."
    reference: "Reference sequence fasta file."
    reference_novoindex: "Reference sequence file index with NovoIndex."
    reference_idx: "Reference sequence index (.fai)."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    version: "0.1.0"
  }
}

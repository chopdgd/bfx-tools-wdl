version 1.0
# -------------------------------------------------------------------------------------------------
# Workflow Summary: FASTQ to BAM pipeline using NovoAlign, Samtools, and Picard
# Tools Used:
#  * NovoAlign
#  * Samtools sort
#  * Picard MarkDuplicates
#  * GATK HaplotypeCaller in ERC mode
# -------------------------------------------------------------------------------------------------

import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.4.1/utilities/CombineFastQ.wdl" as CombineFastQ
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.4.1/novoalign/NovoAlignAndSamtoolsSort.wdl" as NovoAlign
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.4.1/picard/MarkDuplicates.wdl" as Picard
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.4.1/gatk/HaplotypeCallerERC.wdl" as GATK

workflow FastQToGVCF {
  input {
    String sample_id
    File fastq_1
    Array[File] additional_fastq1
    File fastq_2
    Array[File] additional_fastq2
    File intervals

    File ? java
    File ? novoalign
    File novoalign_license
    File ? samtools
    File ? picard
    File ? gatk

    File reference_novoindex
    File reference
    File reference_idx
    File reference_dict

    File ? dbsnp
    File ? dbsnp_idx
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

  call NovoAlign.NovoAlignAndSamtoolsSort as Alignment {
    input:
      novoalign=novoalign,
      novoalign_license=novoalign_license,
      samtools=samtools,
      reference_novoindex=reference_novoindex,
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
      intervals=[intervals],
      sample_id=sample_id,
      bam_file=MarkDuplicates.bam_file,
      bam_idx_file=MarkDuplicates.bam_idx_file,
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
  }

  parameter_meta {
    sample_id: "Sample ID to use in SAM TAG."
    fastq_1: "FASTQ Files left reads."
    fastq_2: "FASTQ Files right reads."
    intervals: "One or more genomic intervals over which to operate."
    java: "Path to Java."
    novoalign: "NovoAlign executable."
    novoalign_license: "NovoAlign License."
    samtools: "Samtools executable."
    picard: "Picard jar file."
    gatk: "GATK jar file."
    reference: "Reference sequence fasta file."
    reference_novoindex: "Reference sequence file index with NovoIndex."
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

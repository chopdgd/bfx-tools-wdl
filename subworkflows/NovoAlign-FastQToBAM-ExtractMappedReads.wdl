version 1.0
# -------------------------------------------------------------------------------------------------
# Workflow Summary: FASTQ to BAM pipeline using NovoAlign, Samtools, and Picard
# Tools Used:
#  * NovoAlign
#  * Samtools sort
#  * Picard MarkDuplicates
# -------------------------------------------------------------------------------------------------

import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.0.0/utilities/CombineFastQ.wdl" as CombineFastQ
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.0.0/novoalign/NovoAlignAndSamtoolsSort.wdl" as NovoAlign
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/extract-mapped-reads-modify-reference-optional/samtools/ExtractMappedReads.wdl" as ExtractMappedReads
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.0.0/picard/MarkDuplicates.wdl" as Picard

workflow FastQToMappedBAM {
  input {
    String sample_id
    File fastq_1
    Array[File] additional_fastq1
    File fastq_2
    Array[File] additional_fastq2

    File ? novoalign
    File novoalign_license
    File ? samtools
    File ? picard

    File reference_novoindex
    File reference
    File reference_idx
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

  call ExtractMappedReads.ExtractMappedReads as ExtractMapped {
    input:
      samtools=samtools,
      reference=reference,
      reference_idx=reference_idx,
      input_bam_file=Alignment.bam_file,
      input_bam_idx_file=Alignment.bam_idx_file,
  }

  output {
    # BAMs
    File bam_file = ExtractMapped.bam_file
    File bam_idx_file = ExtractMapped.bam_idx_file

    # QC
    File alignment_metrics_file = Alignment.metrics_file
    File markdups_metrics_file = MarkDuplicates.metrics_file
  }

  parameter_meta {
    sample_id: "Sample ID to use in SAM TAG."
    fastq_1: "FASTQ Files left reads."
    fastq_2: "FASTQ Files right reads."
    novoalign: "NovoAlign executable."
    novoalign_license: "NovoAlign License."
    samtools: "Samtools executable."
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

version 1.0
# -------------------------------------------------------------------------------------------------
# Workflow Summary: FASTQ to BAM pipeline using GSnap Circular Aligner, Samtools, and Picard
# Tools Used:
#  * GSnap
#  * Samtools sort
#  * Samtools ExtractMappedReads
#  * Picard MarkDuplicates
# -------------------------------------------------------------------------------------------------

import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.0.0/utilities/CombineFastQ.wdl" as CombineFastQ
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.0.0/gsnap/GsnapAndSamtools.wdl" as CircularMapping
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.0.0/samtools/ExtractMappedReads.wdl" as ExtractMappedReads

workflow  FastQToCircularBAM {
  input {
    String sample_id
    File fastq_1
    Array[File] additional_fastq1
    File fastq_2
    Array[File] additional_fastq2

    File ? gsnap
    File ? samtools

    File circular_reference_dir
    String circular_reference_name
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

  call CircularMapping.GSnap as GsnapAlignment {
    input:
      gsnap=gsnap,
      samtools=samtools,
      reference_dir=circular_reference_dir,
      reference_name=circular_reference_name,
      sample_id=sample_id,
      fastq_1=CombineRead1.output_file,
      fastq_2=CombineRead2.output_file,
  }

  call ExtractMappedReads.ExtractMappedReads as ExtractMapped {
    input:
      samtools=samtools,
      input_bam_file=GsnapAlignment.bam_file,
      input_bam_idx_file=GsnapAlignment.bam_idx_file,
  }

  output {
    # BAMs
    File bam_file = ExtractMapped.bam_file
    File bam_idx_file = ExtractMapped.bam_idx_file

  }

  parameter_meta {
    sample_id: "Sample ID to use in SAM TAG."
    fastq_1: "FASTQ Files left reads."
    fastq_2: "FASTQ Files right reads."
    gsnap: "GSnap executable."
    samtools: "Samtools executable."
    reference: "Reference sequence fasta file."
    reference_novoindex: "Reference sequence file index with NovoIndex."
    reference_idx: "Reference sequence index (.fai)."
  }

  meta {
    author: "Pushkala Jayaraman"
    email: "jayaramanp@email.chop.edu"
    version: "0.1.0"
  }
}

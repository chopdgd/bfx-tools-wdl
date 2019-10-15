version 1.0
# -------------------------------------------------------------------------------------------------
# Workflow Summary: FASTQ to BAM pipeline using NovoAlign, Samtools, and Picard
# Tools Used:
#  * NovoAlign
#  * Samtools sort
#  * Picard MarkDuplicates
# -------------------------------------------------------------------------------------------------

import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.1.0/utilities/CombineFastQ.wdl" as CombineFastQ
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.1.0/novoalign/NovoAlignAndSamtoolsSort.wdl" as NovoAlign
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/featureMitoIH14-circular-alignment/gsnap/GsnapAndSamtools.wdl" as Gsnap
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.1.0/picard/MarkDuplicates.wdl" as Picard

workflow FastQGsnapToBAM {
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
    File ? gsnap

    File reference_novoindex
    File reference
    File reference_idx
    String circular_reference_dir
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

  call NovoAlign.NovoAlignAndSamtoolsSort as NovoAlign {
    input:
      sample_id=sample_id,
      fastq_1=CombineRead1.output_file,
      fastq_2=CombineRead2.output_file,
      novoalign=novoalign,
      novoalign_license=novoalign_license,
      samtools=samtools,
      reference_novoindex=reference_novoindex,
      reference=reference,
      reference_idx=reference_idx,
  }

  call Gsnap.GsnapAndSamtools as Gsnap {
    input:
      sample_id=sample_id,
      fastq_1=CombineRead1.output_file,
      fastq_2=CombineRead2.output_file,
      samtools=samtools,
      gsnap=gsnap,
      reference=reference,
      reference_idx=reference_idx,
      circular_reference_dir=circular_reference_dir,
      circular_reference_name=circular_reference_name,
  }

  call Picard.MarkDuplicates as MarkDuplicates {
    input:
      picard=picard,
      reference=reference,
      reference_idx=reference_idx,
      sample_id=sample_id,
      input_file=NovoAlign.bam_file,
  }

  output {
    # BAMs
    File shifted_bam_file = NovoAlign.bam_file
    File shifted_bam_idx_file = NovoAlign.bam_idx_file
    File circular_bam_file = Gsnap.bam_file
    File circular_bam_idx_file = Gsnap.bam_idx_file
    File markdups_bam_file = MarkDuplicates.bam_file
    File markdups_bam_idx_file = MarkDuplicates.bam_idx_file

    # QC
    File alignment_metrics_file = NovoAlign.metrics_file
    File markdups_metrics_file = MarkDuplicates.metrics_file
  }

  parameter_meta {
    sample_id: "Sample ID to use in SAM TAG."
    fastq_1: "FASTQ Files left reads."
    fastq_2: "FASTQ Files right reads."
    novoalign: "NovoAlign executable."
    novoalign_license: "NovoAlign License."
    samtools: "Samtools executable."
    picard: "Picard jar file."
    circular_reference_dir: "Path to Gsnap reference files for circular alignment"
  }

  meta {
    author: "Tolga Ayazseven"
    email: "Ayazsevent@email.chop.edu"
    version: "0.1.0"
  }
}

version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/broadinstitute/rnaseqc
# Task Summary: Fast, efficient RNA-Seq metrics for quality control and process optimization
# Tool Name: RNA-SeQC
# Documentation: https://github.com/broadinstitute/rnaseqc/blob/master/README.md
# -------------------------------------------------------------------------------------------------

task RNASeQC {
  input {
    File gtf
    File bam_file

    String sample_id
    String output_directory = "."

    String userString = "--coverage"

    File image
    Float memory = 12
    Int cpu = 1
  }

  command {
    set -Eeuxo pipefail;

    rnaseqc \
      --sample ~{sample_id} \
      ~{gtf} \
      ~{bam_file} \
      ~{output_directory} \
      ~{userString}
  }

  output {
    File metrics_tsv = "~{sample_id}" + '.metrics.tsv'
    File exon_reads = "~{sample_id}" + '.exon_reads.gct'
    File gene_reads = "~{sample_id}" + '.gene_reads.gct'
    File gene_tuple_reads = "~{sample_id}" + '.gene_tpm.gct'
    File coverage_tsv = "~{sample_id}" + '.coverage.tsv'
  }

  runtime {
    singularity: true
    image: image
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    gtf: "The input GTF file containing features to check the bam against (must be collapsed)."
    bam_file: "The input BAM file (with readgroups) containing reads to process."
    sample_id: "Prefix for output files."
    output_directory: "Output directory."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    rnaseqc_version: "2.3.1"
    version: "0.2.0"
  }
}

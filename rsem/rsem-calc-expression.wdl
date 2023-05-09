version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/deweylab/RSEM
# Task Summary: estimates gene and isoform expression levels from RNA-Seq data
# Tool Name: rsem-calculate-expression
# Documentation: http://deweylab.biostat.wisc.edu/rsem/rsem-calculate-expression.html
# -------------------------------------------------------------------------------------------------

task RSEMExpr {
  input {
    File bam_file
    String reference_directory
    String sample_id

    Float forward_prob = 0.5

    String userString = "--paired-end --no-bam-output --no-qualities"

    File image
    Float memory = 24
    Int cpu = 12
  }

  command {
    set -Eeuxo pipefail;

    rsem-calculate-expression \
      --num-threads ~{cpu} \
      ~{userString} \
      --forward-prob ~{forward_prob} \
      --bam ~{bam_file} \
      ~{reference_directory} \
      ~{sample_id}
  }

  output {
    File isoforms_result = "~{sample_id}" + '.isoforms.results'
    File genes_results = "~{sample_id}" + '.genes.results'
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    bam_file: "Aligned transcriptome BAM."
    reference_directory: "pre-built reference directory; built with rsem-prepare-reference."
    sample_id: "prefix for output files."
    forward_prob: "Probability of generating a read from the forward strand of a transcript."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    rsem_version: "1.3.1"
    version: "0.2.0"
  }
}

version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/deweylab/RSEM
# Task Summary: estimates gene and isoform expression levels from RNA-Seq data
# Tool Name: rsem-calculate-expression
# Documentation: http://deweylab.biostat.wisc.edu/rsem/rsem-calculate-expression.html
# -------------------------------------------------------------------------------------------------

task RSEMExpr {
  input {
    File rsem
    File bam_file
    File reference
    String sample_id

    Float forward_prob = 0.5

    Array[String] modules = []
    Float memory = 12
    Int cpu = 12
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{rsem} \
      --num-threads ~{cpu} \
      --paired-end \
      --no-bam-output \
      --no-qualities \
      --forward-prob ~{forward_prob} \
      --bam ~{bam_file} \
      ~{reference} \
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
    rsem: "Path to rsem-calculate-expression."
    bam_file: "Aligned transcriptome BAM."
    reference: "pre-built reference directory; built with rsem-prepare-reference."
    sample_id: "prefix for output files."
    forward_prob: "Probability of generating a read from the forward strand of a transcript."
    modules: "Modules to load when task is called; modules must be compatible with the platform the task runs on."
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

version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://pachterlab.github.io/kallisto
# Task Summary: Quantifies abundances of transcripts from RNA-Seq data using pseudo-alignment
# Tool Name: Kallisto
# Documentation: https://pachterlab.github.io/kallisto/manual
# -------------------------------------------------------------------------------------------------

task Kallisto {
  input {
    File kallisto
    File kallisto_index
    String output_path = "."
    Array[File] fastqs

    Array[String] modules = []
    Float memory = 8
    Int cpu = 4
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{kallisto} \
      quant \
      -i ~{kallisto_index} \
      -o ~{output_path} \
      --fusion \
      -b 10 \
      --threads ~{cpu} \
      ~{sep=' ' fastqs}
  }

  output {
    File fusion_out = 'fusion.txt'
    File abundance_tsv_out = 'abundance.tsv'
    File abundance_h5_out = 'abundance.h5'
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    kallisto: "Path to kallisto."
    kallisto_index: "Index file built using the kallisto 'index' command."
    output_path: "The directory to write the output."
    fastqs: "The reads to align to the kallisto index."
    modules: "Modules to load when task is called; modules must be compatible with the platform the task runs on."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    kallisto_version: "0.45.0"
    version: "0.2.0"
  }
}

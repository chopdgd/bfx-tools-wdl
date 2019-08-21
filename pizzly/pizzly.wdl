version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/pmelsted/pizzly
# Task Summary: Detects gene fusions from RNA-Seq data downstream of Kallisto
# Tool Name: Pizzly
# Documentation: https://github.com/pmelsted/pizzly/blob/master/README.md
# -------------------------------------------------------------------------------------------------

task Pizzly {
  input {
    File pizzly

    File transcript_fasta
    File gtf
    File fusion_file

    String sample_id

    Int align_score = 2
    Int insert_size = 400

    Array[String] modules = []
    Float memory = 1
    Int cpu = 1
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{pizzly} \
      -k 31 \
      --fasta ~{transcript_fasta} \
      --gtf ~{gtf} \
      --align-score ~{align_score} \
      --insert-size ~{insert_size} \
      --output ~{sample_id} \
      ~{fusion_file}
  }

  output {
    File unfiltered_fusion_fasta = "~{sample_id}" + '.unfiltered.fusions.fasta'
    File unfiltered_fusion_json = "~{sample_id}" + '.unfiltered.json'
    File filtered_fusion_fasta = "~{sample_id}" + '.fusions.fasta'
    File filtered_fusion_json = "~{sample_id}" + '.json'
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    pizzly: "Path to pizzly."
    transcript_fasta: "The reference fasta used to make the upstream kallisto index."
    gtf: "GTF annotation file."
    fusion_file: "Fusion file output from upstream kallisto task."
    sample_id: "Prefix for output files."
    align_score: "The number of mismatches allowed when aligning reads to a reference transcript."
    insert_size: "The maximum insert size of the paired-end library."
    modules: "Modules to load when task is called; modules must be compatible with the platform the task runs on."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    pizzly_version: "0.37.3"
    version: "0.2.0"
  }
}

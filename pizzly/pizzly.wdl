version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/pmelsted/pizzly
# Task Summary: Detects gene fusions from RNA-Seq data downstream of Kallisto
# Tool Name: Pizzly
# Documentation: https://github.com/pmelsted/pizzly/blob/master/README.md
# -------------------------------------------------------------------------------------------------

task Pizzly {
  input {
    File transcript_fasta
    File gtf
    File fusion_file
    String sample_id

    String userString = "-k 31"

    Int align_score = 2
    Int insert_size = 400

    File image
    Float memory = 12
    Int cpu = 1
  }

  command {
    set -Eeuxo pipefail;

    pizzly \
      --fasta ~{transcript_fasta} \
      --gtf ~{gtf} \
      ~{userString} \
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
    singularity: true
    image: image
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    transcript_fasta: "The reference fasta used to make the upstream kallisto index."
    gtf: "GTF annotation file."
    fusion_file: "Fusion file output from upstream kallisto task."
    sample_id: "Prefix for output files."
    align_score: "The number of mismatches allowed when aligning reads to a reference transcript."
    insert_size: "The maximum insert size of the paired-end library."
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

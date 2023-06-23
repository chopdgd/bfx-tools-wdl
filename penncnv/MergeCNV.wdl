version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://penncnv.openbioinformatics.org/en/latest/
# Task Summary: SNP Array CNV Annotation
# Tool Name: PennCNV
# Documentation: http://penncnv.openbioinformatics.org/en/latest/user-guide/download/
# -------------------------------------------------------------------------------------------------

task MergeCNV {
  input {
    String script = "/home/user/PennCNV/clean_cnv.pl"
    String image
    String input_file
    File signal_file

    # Run time variables
    Float memory = 12
    Int cpu = 1

    String output_filename = "merged_cnv_calls.tsv"
  }

  command {
    set -Eeuxo pipefail;

    ~{script} \
      combineseg \
      ~{input_file} \
      --signalfile \
      ~{signal_file} \
      --output \
      ~{output_filename};
  }

  output {
    File output_file = output_filename
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
    singularity: true
    image: image
  }

  parameter_meta {
    script: "Path to penncnv clean_cnv.pl script in Singularity image"
    image: "Path to Singularity image"
    input_file: "PennCNV raw CNV file"
    signal_file: "Genome Studio SNP Array file"
    output_filename: "Output filename"
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Adam Gleason"
    email: "gleasona@email.chop.edu"
    version: "1.0.0"
  }
}

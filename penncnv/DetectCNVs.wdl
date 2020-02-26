version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://penncnv.openbioinformatics.org/en/latest/
# Task Summary: SNP Array CNV Caller
# Tool Name: PennCNV
# Documentation: http://penncnv.openbioinformatics.org/en/latest/user-guide/download/
# -------------------------------------------------------------------------------------------------

task DetectCNVs {
  input {
    String script  # NOTE: PennCNV needs to run in its own folder
    File input_file
    File hmm_file
    File pfb_file
    String log_file

    String ? sex_flag = ""  # NOTE: PennCNV needs -chrX flag to call on Sex Chr

    # Run time variables
    Float memory = 4
    Int cpu = 1
    Array[String] modules = []

    String output_filename
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    perl ~{script} \
      -test \
      ~{input_file} \
      ~{sex_flag} \
      -hmm ~{hmm_file} \
      -pfb ~{pfb_file} \
      -log ~{log_file} \
      -out ~{output_filename};
  }

  output {
    File cnv_file = "~{output_filename}"
    File log_file = "~{log_file}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    script: "penncnv detect cnvs script"
    input_file: "GenomeStudio SNP Array Data"
    hmm_file: "penncnv hmm file"
    pfb_file: "penncnv pfb file"
    log_file: "penncnv log file"
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Adam Gleason"
    email: "gleasona@email.chop.edu"
    version: "1.0.0"
  }
}

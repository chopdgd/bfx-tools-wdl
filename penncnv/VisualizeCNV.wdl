version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://penncnv.openbioinformatics.org/en/latest/
# Task Summary: SNP Array CNV Annotation
# Tool Name: PennCNV
# Documentation: http://penncnv.openbioinformatics.org/en/latest/user-guide/download/
# -------------------------------------------------------------------------------------------------

task VisualizeCNV {
  input {
    String script  # NOTE: PennCNV needs to run in its own folder
    File input_file
    File idmap_file

    # Run time variables
    Float memory = 4
    Int cpu = 1
    Array[String] modules = []

    String output_filename = "project_cnvs.xml"
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    perl ~{script} \
      -format beadstudio \
      -idmap \
      ~{idmap_file} \
      -output \
      ~{output_filename} \
      ~{input_file};
  }

  output {
    File output_file = output_filename
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    script: "PAth to penncnv visualize_cnv.pl script"
    input_file: "PennCNV raw CNV file"
    idmap_file: "a file continaing file name (in PennCNV call) and sample id (in BeadStudio) mapping"
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

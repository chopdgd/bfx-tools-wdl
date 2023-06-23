version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://penncnv.openbioinformatics.org/en/latest/
# Task Summary: SNP Array CNV Annotation
# Tool Name: PennCNV
# Documentation: http://penncnv.openbioinformatics.org/en/latest/user-guide/download/
# -------------------------------------------------------------------------------------------------

task VisualizeCNV {
  input {
    String script = "/home/user/PennCNV/visualize_cnv.pl"
    String image
    String input_file
    File idmap_file

    # Run time variables
    Float memory = 12
    Int cpu = 1

    String output_filename = "project_cnvs.xml"
  }

  command {
    set -Eeuxo pipefail;

    ~{script} \
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
    singularity: true
    image: image
  }

  parameter_meta {
    script: "Path to penncnv visualize_cnv.pl script in Singularity image"
    image: "Path to Singularity image"
    input_file: "PennCNV raw CNV file"
    idmap_file: "a file containing file name (in PennCNV call) and sample id (in BeadStudio) mapping"
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

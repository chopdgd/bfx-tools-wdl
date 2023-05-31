version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://penncnv.openbioinformatics.org/en/latest/
# Task Summary: SNP Array CNV Annotation
# Tool Name: PennCNV
# Documentation: http://penncnv.openbioinformatics.org/en/latest/user-guide/download/
# -------------------------------------------------------------------------------------------------

task ScanRegion {
  input {
    String script = "/home/user/PennCNV/scan_region.pl"
    String image
    String input_file
    File refgene_file

    # Run time variables
    Float memory = 12
    Int cpu = 1
    Array[String] modules = []
  }

  command {
    set -Eeuxo pipefail;

    ~{script} \
      ~{input_file} \
      ~{refgene_file} \
      -refgene \
      -name2;
  }

  output {
    File output_file = stdout()
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
    singularity: true
    image: image
  }

  parameter_meta {
    script: "Path to penncnv scan_region.pl script in Singularity image"
    image: "Path to Singularity image"
    input_file: "GenomeStudio SNP Array Data"
    refgene_file: "UCSC refGene.txt"
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Adam Gleason"
    email: "gleasona@email.chop.edu"
    version: "1.0.0"
  }
}

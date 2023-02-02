version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: Vt
# Task Summary: Combine two vcf with same headers
# Tool Name: Vt
# Documentation:
#  * https://genome.sph.umich.edu/wiki/Vt#Concatenate
# -------------------------------------------------------------------------------------------------


task CatVCF {
  input {
    File ? vt

    Array[File] input_files

    Array[String] modules = []
    Float memory = 24
    Int cpu = 1

    String output_filename
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="vt" vt} cat \
      ~{sep=" " input_files} | \
    ~{default="vt" vt} sort - \
      -o ~{output_filename};

  }

  output {
    File vcf_file = "~{output_filename}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    vt: "Vt executable."
    input_files: "VCF files need to combine"
    output_filename: "output file name"
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Weixuan Fu"
    email: "fuw@chop.edu"
    vt_version: "v0.5772-60f436c3"
    version: "0.1.0"
  }
}

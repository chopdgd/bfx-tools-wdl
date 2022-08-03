version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: Vt
# Task Summary: Remove info from a VCF
# Tool Name: Vt
# Documentation:
#  * https://genome.sph.umich.edu/wiki/Vt#Rminfo
# -------------------------------------------------------------------------------------------------


task RminfoVCF {
  input {
    File ? vt
    File input_file
    File ? input_idx_file

    String infotag

    Array[String] modules = []
    Float memory = 12
    Int cpu = 1

    String output_filename = basename(input_file) + ".rminfo.vcf"
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="vt" vt} rminfo \
      -t ~{infotag} \
      -o ~{output_filename} ~{input_file};
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
    input_file: "VCF file."
    input_idx_file: "VCF file index (.tbi)."
    infotag: "info tag need to be removed."
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

version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: slivar
# Task Summary: filter/annotate variants in VCF/BCF format with simple expressions
# Tool Name: make-gnotate
# Documentation: https://github.com/brentp/slivar/wiki/make-gnotate
# -------------------------------------------------------------------------------------------------


task makeGnotate {
  input {
    File ? slivar
    File vcf_file
    File ? vcf_idx_file
    String prefix

    String ? userString

    Array[String] modules = []
    Float memory = 4
    Int cpu = 1
  }

  String output_filename = prefix + '.zip'

    command {
      set -Eeuxo pipefail;

      for MODULE in ~{sep=' ' modules}; do
          module load $MODULE
      done;

      ~{default="slivar" slivar} make-gnotate \
        --prefix ~{prefix} \
        ~{userString} \
        ~{vcf_file}
  }

  output {
    File output_file = "~{output_filename}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    slivar: "Path to slivar binary."
    vcf_file: "VCF file to annotate."
    vcf_idx_file: "VCF file index (.tbi)"
    prefix: "Prefix to use for output zip file"
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    slivar_version: "0.1.6"
    version: "0.1.0"
  }
}

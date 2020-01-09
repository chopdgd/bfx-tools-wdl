version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: slivar
# Task Summary: filter/annotate variants in VCF/BCF format with simple expressions
# Tool Name: expr
# Documentation: https://github.com/brentp/slivar#expr
# -------------------------------------------------------------------------------------------------


task expr {
  input {
    File ? slivar
    File vcf_file
    File ? vcf_idx_file
    File ? bed_file
    File ? ped_file
    File ? group_file
    File ? javascript_file
    File ? gnotate_file

    String prefix
    Boolean pass_only = true
    String ? userString

    Array[String] modules = []
    Float memory = 4
    Int cpu = 1

    String output_filename = prefix + '.slivar.expr.vcf'
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="slivar" slivar} expr \
      ~{true='--pass-only' false='' pass_only} \
      --vcf ~{vcf_file} \
      ~{"--region " + bed_file} \
      ~{"--ped " + ped_file} \
      ~{"--alias " + group_file} \
      ~{"--js " + javascript_file} \
      ~{"--gnotate " + gnotate_file} \
      ~{userString} \
      --out-vcf ~{output_filename};
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
    bed_file: "Regions to filter"
    ped_file: "PED file"
    group_file: "Alias file"
    javascript_file: "JavaScript functions file"
    gnotate_file: "gnotate file"
    pass_only: "If --pass-only should be used"
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

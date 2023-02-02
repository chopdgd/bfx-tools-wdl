version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: bcftools concat
# Task Summary: Concatenate or combine VCF/BCF files.
#      All source files must have the same sample columns appearing in the same order.
# Tool Name: bcftools concat
# Documentation:
#  * https://https://samtools.github.io/bcftools/bcftools.html
# -------------------------------------------------------------------------------------------------


task BCFToolsConcat {
  input {
    # Tools
    File ? bcftools

    # Inputs
    Array[File] input_files
    Array[File] input_idx_files
    String sample_id
    String userString = "-D -a -O z"

    # Run time variables
    Array[String] modules = []
    Float memory = 12
    Int cpu = 1

    # Output file names
    String output_filename = sample_id + ".concat.vcf.gz"
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="bcftools" bcftools} concat \
      ~{userString} \
      -o ~{output_filename} \
      ~{sep=" " input_files}
  }

  output {
    File output_file = "~{output_filename}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    sample_id: "sample id"
    bcftools: "bcftools executable."
    input_files: "VCF files"
  }

  meta {
    author: "Weixuan Fu"
    email: "fuw@chop.edu"
    bcftools_version: "1.9"
    version: "1.0.0"
  }
}

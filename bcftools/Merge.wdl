version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: bcftools merge
# Task Summary: merge  multi VCFs into one
# Tool Name: bcftools merge
# Documentation:
#  * https://https://samtools.github.io/bcftools/bcftools.html
# -------------------------------------------------------------------------------------------------


task BCFToolsMerge {
  input {
    # Tools
    File ? bcftools

    # Inputs
    Array[File] input_files
    Array[File] input_idx_files
    String sample_id
    String userString = "-i DP:join,SAP:min,SRP:min,RPP:min -m none -O z"

    # Run time variables
    Array[String] modules = []
    Int memory = 4
    Int cpu = 1
  }
  # Output file names
  String output_filename = sample_id + ".merged.vcf.gz"

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="bcftools" bcftools} merge \
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
    author: "Cao K"
    email: "caok@email.chop.edu"
    bcftools_version: "1.8-27-gb0376df"
    version: "0.1.0"
  }
}

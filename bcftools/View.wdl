version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: bcftools sort
# Task Summary: sort VCF file
# Tool Name: bcftools sort
# Documentation:
#  * https://https://samtools.github.io/bcftools/bcftools.html
# -------------------------------------------------------------------------------------------------


task BCFToolsView {
  input {
    # Tools
    File ? bcftools

    # Inputs
    File input_file
    File ? input_idx_file
    String sample_id
    File ? region_bed
    String ? userString
    String filename_prefix = ""

    # Run time variables
    Array[String] modules = []
    Float memory = 12
    Int cpu = 1

    # Output file names
    String output_filename = sample_id + filename_prefix + ".viewed.vcf"
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="bcftools" bcftools} view \
      ~{userString} \
      ~{"-R " + region_bed} \
      -o ~{output_filename} \
      ~{input_file};
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
    input_file: "VCF file"
    region_bed: "regions to view"
  }

  meta {
    author: "Weixuan Fu"
    email: "fuw@chop.edu"
    bcftools_version: "1.9"
    version: "1.0.0"
  }
}

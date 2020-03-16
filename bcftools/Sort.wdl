version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: bcftools sort
# Task Summary: sort VCF file
# Tool Name: bcftools sort
# Documentation:
#  * https://https://samtools.github.io/bcftools/bcftools.html
# -------------------------------------------------------------------------------------------------


task BCFToolsSort {
  input {
    # Tools
    File ? bcftools

    # Inputs
    File input_file
    String sample_id
    String ? userString
    String filename_prefix = ""

    # Run time variables
    Array[String] modules = []
    Float memory = 4
    Int cpu = 1

    # Output file names
    String output_filename = sample_id + filename_prefix + ".sorted.vcf"
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="bcftools" bcftools} sort \
      ~{userString} \
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
  }

  meta {
    author: "Tolga Ayazseven"
    email: "ayazsevent@email.chop.edu"
    bcftools_version: "1.9"
    version: "1.0.0"
  }
}

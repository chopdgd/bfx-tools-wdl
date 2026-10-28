version 1.0

# -------------------------------------------------------------------------------------------------
# Package Name: bcftools isec
# Task Summary: intersect VCF files
# Tool Name: bcftools isec
# Documentation:
#  * https://samtools.github.io/bcftools/bcftools.html#isec
# -------------------------------------------------------------------------------------------------


# Used to subsample VCF A by calls in VCF B, yielding a single filtered VCF A
# "-c none" is an explicit declaration that matches are on exact REF/ALT
# so multiallelic sites can have issues. Decompose and normalize first!!!!!
task BCFToolsIsec {
  input {
    # Tools
    File? bcftools

    # Inputs
    Array[File] input_files
    Array[File] input_idx_files
    String sample_id
    String userString = "-n=2 -w1 -c none -Oz"

    # Run time variables
    Array[String] modules = []
    Float memory = 12
    Int cpu = 1

    # Output file names
    String output_filename = sample_id + ".isec.vcf.gz"
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load "$MODULE"
    done;

    ~{default="bcftools" bcftools} isec \
      ~{userString} \
      -o "~{output_filename}" \
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
    sample_id: "Sample ID."
    bcftools: "bcftools executable."
    input_files: "Sorted, compressed VCF files. With default options, provide the primary VCF first and the comparison VCF second."
    input_idx_files: "VCF indexes, which must be localized alongside their corresponding VCFs with matching filenames."
    userString: "bcftools isec options. Defaults to exact allele matching in two files, writing records from the first file."
  }

  meta {
    version: "0.1.0"
  }
}
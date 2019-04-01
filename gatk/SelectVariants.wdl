version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://software.broadinstitute.org/gatk/
# Task Summary: Select a subset of variants from a larger callset
# Tool Name: GATK SelectVariants
# Documentation: https://software.broadinstitute.org/gatk/documentation/tooldocs/3.8-0/org_broadinstitute_gatk_tools_walkers_variantutils_SelectVariants.php
# Example: https://software.broadinstitute.org/wdl/documentation/article?id=7615
# -------------------------------------------------------------------------------------------------


task SelectVariants {
  input {
    File ? java
    File ? gatk
    File reference
    File reference_idx
    File reference_dict

    Array[File] intervals
    File input_file
    File ? input_idx_file

    Array[String] selectType
    Array[String] selectTypeToExclude
    Array[String] selectExpressions
    String ? userString

    Array[String] modules = []
    Int memory = 4
    Int cpu = 1
  }

  String output_filename = basename(input_file) + ".filtered.vcf.gz"
  String output_idx_filename = basename(input_file) + ".filtered.vcf.gz.tbi"

  command {
    set -Eeuxo pipefail;

    for MODULE in ${sep=' ' modules}; do
      module load $MODULE
    done;

    ${default="java" java} \
      -Xmx${memory}g \
      -jar ${default="gatk" gatk} \
      -T SelectVariants \
      ${userString} \
      -R ${reference} \
      -nt ${cpu} \
      --variant ${input_file} \
      ${sep=" " prefix("--intervals ", intervals)} \
      ${sep=" " prefix("--selectTypeToInclude ", selectType)} \
      ${sep=" " prefix("--selectTypeToExclude ", selectTypeToExclude)} \
      ${sep=" " prefix("--selectexpressions ", selectExpressions)} \
      -o ${output_filename};
  }

  output {
    File vcf_file = "${output_filename}"
    File vcf_idx_file = "${output_idx_filename}"
  }

  runtime {
    memory: memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    java: "Path to Java."
    gatk: "GATK jar file."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    reference_dict: "Reference sequence dict (.dict)."
    intervals: "One or more genomic intervals over which to operate."
    input_file: "One VCF file."
    input_idx_file: "VCF index file (.tbi)."
    selectType: "Select only a certain type of variants from the input file."
    selectTypeToExclude: "Do not select certain type of variants from the input file."
    selectExpressions: "One or more criteria to use when selecting the data."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    gatk_version: "3.8"
    version: "0.1.0"
  }
}

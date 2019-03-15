version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://software.broadinstitute.org/gatk/
# Task Summary: Select a subset of variants from a larger callset
# Tool Name: GATK SelectVariants
# Documentation: https://software.broadinstitute.org/gatk/documentation/tooldocs/3.8-0/org_broadinstitute_gatk_tools_walkers_variantutils_SelectVariants.php
# Example: https://software.broadinstitute.org/wdl/documentation/article?id=7615
# -------------------------------------------------------------------------------------------------

import "https://raw.githubusercontent.com/genomics-geek/bfx-tools-wdl/master/structs/Resources.wdl"

task SelectVariants {
  input {
    File ? java
    File gatk
    ReferenceFasta reference

    Array[File] intervals
    File input_file
    File ? input_idx_file

    Array[String] selectType
    Array[String] selectTypeToExclude
    Array[String] selectExpressions
    String ? userString

    Int ? memory
    Int ? cpu
  }

  String output_filename = basename(input_file) + ".filtered.vcf.gz"
  String output_idx_filename = basename(input_file) + ".filtered.vcf.gz.tbi"

  command {
    ${default="java" java} \
      -Xmx${default=4 memory}g \
      -jar ${gatk} \
      -T SelectVariants ${userString} \
      -R ${reference.reference} \
      -nt ${default=1 cpu} \
      --variant ${input_file} \
      ${sep=" " prefix("--intervals ", intervals)} \
      ${sep=" " prefix("--selectTypeToInclude ", selectType)} \
      ${sep=" " prefix("--selectTypeToExclude ", selectTypeToExclude)} \
      ${sep=" " prefix("--selectexpressions ", selectExpressions)} \
      -o ${output_filename}
  }

  output {
    File output_file = "${output_filename}"
    File output_file_idx = "${output_idx_filename}"
  }

  runtime {
    memory: select_first([memory, 4]) * 1.5 + " GB"
    cpu: select_first([cpu, 1])
  }

  parameter_meta {
    java: "Path to Java."
    gatk: "GATK jar file."
    reference: "ReferenceFasta struct that contains Reference sequence file, index (.fai), and dict (.dict)."
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

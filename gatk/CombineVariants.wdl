version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://software.broadinstitute.org/gatk/
# Task Summary: Combine variant records from different sources
# Tool Name: GATK CombineVariants
# Documentation: https://software.broadinstitute.org/gatk/documentation/tooldocs/3.8-0/org_broadinstitute_gatk_tools_walkers_variantutils_CombineVariants.php
# Example: https://software.broadinstitute.org/wdl/documentation/article?id=7615
# -------------------------------------------------------------------------------------------------

import "https://raw.githubusercontent.com/genomics-geek/bfx-tools-wdl/master/structs/Resources.wdl"

task CombineVariants {
  input {
    File ? java
    File gatk
    ReferenceFasta reference

    String filename_prefix
    Array[String] input_files # NOTE: This allows us to add tagging. That's why its a string
    Array[File] input_idx_files

    String ? genotypeMergeOptions
    String ? userString

    Int ? memory
    Int ? cpu
  }

  String output_filename = filename_prefix + ".merged.vcf.gz"
  String output_idx_filename = filename_prefix + ".merged.vcf.gz.tbi"

  command {
    ${default="java" java} \
      -Xmx${default=4 memory}g \
      -jar ${gatk} \
      -T CombineVariants \
      ${userString} \
      -R ${reference} \
      -nt ${default=1 cpu} \
      ${sep=" " prefix("--variant ", input_files)} \
      ${"-genotypeMergeOptions " + genotypeMergeOptions} \
      -o ${output_filename}
    }

  output {
    File vcf_file = "${output_filename}"
    File vcf_idx_file = "${output_idx_filename}"
  }

  runtime {
    memory: select_first([memory, 4]) * 1.5 + " GB"
    cpu: select_first([cpu, 1])
  }

  parameter_meta {
    java: "Path to Java."
    gatk: "GATK jar file."
    reference: "ReferenceFasta struct that contains Reference sequence file, index (.fai), and dict (.dict)."
    filename_prefix: "Prefix of the output VCF filename."
    input_files: "Two or more VCF files."
    input_idx_files: "VCF index files (.tbi)."
    genotypeMergeOptions: "Determines how we should merge genotype records for samples shared across the ROD files."
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

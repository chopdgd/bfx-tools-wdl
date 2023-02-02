version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://software.broadinstitute.org/gatk/
# Task Summary: Combine variant records from different sources
# Tool Name: GATK CombineVariants
# Documentation: https://software.broadinstitute.org/gatk/documentation/tooldocs/3.8-0/org_broadinstitute_gatk_tools_walkers_variantutils_CombineVariants.php
# Example: https://software.broadinstitute.org/wdl/documentation/article?id=7615
# Notes:
#  - tagged_input_files refers to using the command line option of -V:GATK /path/to/file SEE:
# -------------------------------------------------------------------------------------------------


task CombineVariants {
  input {
    File ? java
    File ? gatk
    File reference
    File reference_idx
    File reference_dict

    String filename_prefix
    Array[String] tagged_input_files = [] # NOTE: This allows us to add tagging.
    Array[File] input_files = []
    Array[File] input_idx_files

    String ? genotypeMergeOptions
    String ? userString

    Array[String] modules = []
    Float memory = 12
    Int cpu = 1

    String output_filename = filename_prefix + ".merged.vcf.gz"
    String output_idx_filename = filename_prefix + ".merged.vcf.gz.tbi"
  }

  Int jvm_memory = round(memory)
  Array[String] input_files_with_tags = prefix("--variant", tagged_input_files)
  Array[String] input_files_no_tags = prefix("--variant ", input_files)

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{jvm_memory}g \
      -jar ~{default="gatk" gatk} \
      -T CombineVariants \
      ~{userString} \
      -R ~{reference} \
      -nt ~{cpu} \
      -setKey GATKsetkey \
      ~{sep=" " input_files_with_tags} \
      ~{sep=" " input_files_no_tags} \
      ~{"-genotypeMergeOptions " + genotypeMergeOptions} \
      -o ~{output_filename};
    }

  output {
    File vcf_file = "~{output_filename}"
    File vcf_idx_file = "~{output_idx_filename}"
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
    filename_prefix: "Prefix of the output VCF filename."
    input_files: "Two or more VCF files with no header info"
    tagged_input_files: "Two or more VCF files with header info (i.e. -V:Tag /path/to/file)"
    input_idx_files: "VCF index files (.tbi)."
    genotypeMergeOptions: "Determines how we should merge genotype records for samples shared across the ROD files."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez, Tolga Ayazseven"
    email: "GonzalezMA@email.chop.edu, ayazsevent@email.chop.edu"
    gatk_version: "3.8"
    version: "0.1.0"
  }
}

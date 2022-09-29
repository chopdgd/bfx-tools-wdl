version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://broadinstitute.github.io/picard/
# Task Summary: Converts a BED file to a Picard Interval List.
# Tool Name: Picard BedToIntervalList
# Documentation: https://broadinstitute.github.io/picard/command-line-overview.html#BedToIntervalList
# -------------------------------------------------------------------------------------------------


task MergeVcfs {
  input {
    File ? java
    File ? picard
    File reference_dict
    String sample_id
    Array[File] vcf_files
    String ? userString

    Array[String] modules = []
    Float memory = 16
    Int cpu = 1
    String output_filename = sample_id + ".sorted.vcf"
  }

  Int jvm_memory = round(memory)

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{jvm_memory}g \
      -jar ~{default="picard" picard} SortVCF \
      ~{userString} \
      SD=~{reference_dict} \
      ~{sep=" " prefix("-I ", vcf_files)} \
      O=~{output_filename};
  }

  output {
    File vcf_file = "~{output_filename}"
  }

  runtime {
    memory: memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    java: "Path to Java."
    picard: "Picard jar file."
    reference_dict: "Reference sequence dict (.dict)."
    vcf_files: "vcf file to convert."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "K Cao"
    email: "caok@chop.edu"
    picard_version: "2.27.4"
    version: "0.1.0"
  }
}

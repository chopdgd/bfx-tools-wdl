version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://broadinstitute.github.io/picard/
# Task Summary: Converts a BED file to a Picard Interval List.
# Tool Name: Picard BedToIntervalList
# Documentation: https://broadinstitute.github.io/picard/command-line-overview.html#BedToIntervalList
# -------------------------------------------------------------------------------------------------


task BedToIntervalList {
  input {
    File ? java
    File ? picard
    File reference_dict

    File bed_file

    String validation_stringency = "LENIENT"
    Boolean unique = true
    String ? userString

    Array[String] modules = []
    Float memory = 4
    Int cpu = 1
    String output_filename = basename(bed_file) + ".interval_list"
  }

  Int jvm_memory = round(memory)

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{jvm_memory}g \
      -jar ~{default="picard" picard} BedToIntervalList \
      ~{userString} \
      VALIDATION_STRINGENCY=~{default="LENIENT" validation_stringency} \
      SEQUENCE_DICTIONARY=~{reference_dict} \
      ~{true="UNIQUE=true" false="" unique} \
      INPUT=~{bed_file} \
      OUTPUT=~{output_filename};
  }

  output {
    File interval_list_file = "~{output_filename}"
  }

  runtime {
    memory: memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    java: "Path to Java."
    picard: "Picard jar file."
    reference_dict: "Reference sequence dict (.dict)."
    bed_file: "BED file to convert."
    validation_stringency: "Validation stringency for all SAM files read by this program. Setting stringency to SILENT can improve performance when processing a BAM file in which variable-length data (read, qualities, tags) do not otherwise need to be decoded."
    unique: "Unique the output interval list by merging overlapping regions."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    picard_version: "2.17.8"
    version: "0.1.0"
  }
}

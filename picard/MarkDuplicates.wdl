version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://broadinstitute.github.io/picard/
# Task Summary: Identifies duplicate reads.
# Tool Name: Picard MarkDuplicates
# Documentation: https://broadinstitute.github.io/picard/command-line-overview.html#MarkDuplicates
# -------------------------------------------------------------------------------------------------

import "https://raw.githubusercontent.com/genomics-geek/bfx-tools-wdl/master/structs/Resources.wdl"

task MarkDuplicates {
  input {
    File ? java
    File picard
    ReferenceFasta reference

    String sample_id
    File input_file

    String ? validation_stringency
    Boolean ? remove_duplicates
    String ? sort_order
    Boolean ? create_index

    String ? userString

    Int ? memory
    Int ? cpu
  }

  String metrics_filename = sample_id + ".picardmkdup.metrics"
  String output_filename = sample_id + ".markdups.bam"
  String output_idx_filename = sample_id + ".markdups.bai"

  command {
    ${default="java" java} \
      -Xmx${default=4 memory}g \
      -jar ${picard} MarkDuplicates \
      VALIDATION_STRINGENCY=${default="LENIENT" validation_stringency} \
      REFERENCE_SEQUENCE=${reference.reference} \
      INPUT=${input_file} \
      REMOVE_DUPLICATES=${default=false remove_duplicates} \
      ${"ASSUME_SORT_ORDER=" + sort_order} \
      CREATE_INDEX=${default=true create_index} \
      METRICS_FILE=${metrics_filename} \
      OUTPUT=${output_filename} \
      ${userString}
  }

  output {
    File metrics_file = "${metrics_filename}"
    File bam_file = "${output_filename}"
    File bam_idx_file = "${output_idx_filename}"
  }

  runtime {
    memory: select_first([memory, 4]) * 1.5 + " GB"
    cpu: select_first([cpu, 1])
  }

  parameter_meta {
    java: "Path to Java."
    picard: "Picard jar file."
    reference: "ReferenceFasta struct that contains Reference sequence file, index (.fai), and dict (.dict)."
    sample_id: "prefix for output files."
    input_file: "SAM or BAM file."
    validation_stringency: "Validation stringency for all SAM files read by this program. Setting stringency to SILENT can improve performance when processing a BAM file in which variable-length data (read, qualities, tags) do not otherwise need to be decoded."
    remove_duplicates: "If true do not write duplicates to the output file instead of writing them with appropriate flags set."
    sort_order: "If not null, assume that the input file has this order even if the header says otherwise."
    create_index: "Whether to create a BAM index when writing a coordinate-sorted BAM file."
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

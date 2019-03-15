version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://broadinstitute.github.io/picard/
# Task Summary: Collects hybrid-selection (HS) metrics for a SAM or BAM file
# Tool Name: Picard CollectHsMetrics
# Documentation: http://broadinstitute.github.io/picard/command-line-overview.html#CollectHsMetrics
# -------------------------------------------------------------------------------------------------

task CollectHsMetrics {
  input {
    File ? java
    File picard
    File reference
    File reference_idx

    String sample_id
    File input_file
    File input_idx_file
    File bait_intervals
    File target_intervals

    String ? validation_stringency
    String ? userString

    Int ? memory
    Int ? cpu
  }

  String per_target_coverage_filename = sample_id + ".HsMetrics.target"
  String output_filename = sample_id + ".HsMetrics"

  command {
    ${default="java" java} \
      -Xmx${default=4 memory}g \
      -jar ${picard} CollectHsMetrics \
      VALIDATION_STRINGENCY=${default="LENIENT" validation_stringency} \
      REFERENCE_SEQUENCE=${reference} \
      INPUT=${input_file} \
      BAIT_INTERVALS=${bait_intervals} \
      TARGET_INTERVALS=${target_intervals} \
      PER_TARGET_COVERAGE=${per_target_coverage_filename} \
      OUTPUT=${output_filename} \
      ${userString}
  }

  output {
    File metrics_file = "${output_filename}"
    File per_target_coverage_file = "${per_target_coverage_filename}"
  }

  runtime {
    memory: select_first([memory, 4]) * 1.5 + " GB"
    cpu: select_first([cpu, 1])
  }

  parameter_meta {
    java: "Path to Java."
    picard: "Picard jar file."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    sample_id: "prefix for output files."
    input_file: "Sorted BAM file."
    input_idx_file: "Sorted BAM index file."
    validation_stringency: "Validation stringency for all SAM files read by this program. Setting stringency to SILENT can improve performance when processing a BAM file in which variable-length data (read, qualities, tags) do not otherwise need to be decoded."
    bait_intervals: "An interval list file that contains the locations of the baits used. Default value: null. This option must be specified at least 1 times."
    target_intervals: "An interval list file that contains the locations of the targets. Default value: null. This option must be specified at least 1 times."
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

version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://broadinstitute.github.io/picard/
# Task Summary: Identifies duplicate reads.
# Tool Name: Picard MarkDuplicates
# Documentation: https://broadinstitute.github.io/picard/command-line-overview.html#MarkDuplicates
# -------------------------------------------------------------------------------------------------


task MarkDuplicates {
  input {
    File ? java
    File ? picard
    File reference
    File reference_idx

    String sample_id
    File input_file

    String validation_stringency = "LENIENT"
    Boolean remove_duplicates = false
    String ? sort_order
    Boolean create_index = true
    String ? userString

    Array[String] modules = []
    Int memory = 4
    Int cpu = 1
  }

  String metrics_filename = sample_id + ".picardmkdup.metrics"
  String output_filename = sample_id + ".markdups.bam"
  String output_idx_filename = sample_id + ".markdups.bai"

  command {
    set -Eeuxo pipefail;

    for MODULE in ${sep=' ' modules}; do
        module load $MODULE
    done;

    ${default="java" java} \
      -Xmx${memory}g \
      -jar ${default="picard" picard} MarkDuplicates \
      ${userString} \
      VALIDATION_STRINGENCY=${default="LENIENT" validation_stringency} \
      REFERENCE_SEQUENCE=${reference} \
      INPUT=${input_file} \
      REMOVE_DUPLICATES=${default=false remove_duplicates} \
      ${"ASSUME_SORT_ORDER=" + sort_order} \
      CREATE_INDEX=${create_index} \
      METRICS_FILE=${metrics_filename} \
      OUTPUT=${output_filename};
  }

  output {
    File metrics_file = "${metrics_filename}"
    File bam_file = "${output_filename}"
    File bam_idx_file = "${output_idx_filename}"
  }

  runtime {
    memory: memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    java: "Path to Java."
    picard: "Picard jar file."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
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

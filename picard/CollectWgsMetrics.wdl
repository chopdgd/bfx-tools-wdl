version 1.0

task CollectWgsMetrics {
  input {
    File ? java
    File picard

    File input_bam
    File input_idx_bam
    String filename_prefix

    Array[File] intervals

    File reference
    File reference_idx
    File reference_dict

    String validation_stringency = "SILENT"
    String userString = "USE_FAST_ALGORITHM=true"

    Array[String] modules = []
    Float memory = 16
    Int cpu = 1
  }

  Int jvm_memory = round(memory)
  String output_filename = filename_prefix + ".wgs_metrics.txt"

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{jvm_memory}g \
      -jar ~{default="picard" picard} CollectWgsMetrics \
      INPUT=~{input_bam} \
      OUTPUT=~{output_filename} \
      REFERENCE_SEQUENCE=~{reference} \
      VALIDATION_STRINGENCY=~{validation_stringency} \
      ~{userString} \
      INTERVALS=~{sep=" " intervals}
  }

  output {
    File wgs_metrics = "~{output_filename}"
  }

  runtime {
    memory: jvm_memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    java: "Path to Java."
    picard: "Picard jar file."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    reference_dict: "Reference sequence dictionary (.dict)."
    filename_prefix: "prefix for output files."
    input_bam: "Sorted BAM file."
    input_idx_bam: "Sorted BAM index file."
    validation_stringency: "Validation stringency for all SAM files read by this program. Setting stringency to SILENT can improve performance when processing a BAM file in which variable-length data (read, qualities, tags) do not otherwise need to be decoded."
    intervals: "Interval list files to operate over."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    picard_version: "2.19.0"
    version: "0.1.0"
  }
}

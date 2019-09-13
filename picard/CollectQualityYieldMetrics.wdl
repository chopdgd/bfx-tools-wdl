version 1.0

task CollectQualityYieldMetrics {
  input {
    File ? java
    File picard

    File input_bam
    File input_idx_bam
    String filename_prefix

    String use_original_qualities = "true"
    String ? userString

    Array[String] modules = []
    Float memory = 16
    Int cpu = 1
  }

  Int jvm_memory = round(memory)
  String output_filename = filename_prefix + ".unmapped.quality_yield_metrics"

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{jvm_memory}g \
      -jar ~{default="picard" picard} CollectQualityYieldMetrics \
      ~{userString} \
      USE_ORIGINAL_QUALITIES=~{use_original_qualities} \
      INPUT=~{input_bam} \
      OUTPUT=~{filename_prefix};
  }

  output {
    File quality_yield_metrics = "~{output_filename}"
  }

  runtime {
    memory: jvm_memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    java: "Path to Java."
    picard: "Picard jar file."
    filename_prefix: "prefix for output files."
    input_bam: "Sorted BAM file."
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

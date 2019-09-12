version 1.0

task CollectVariantCallingMetrics {
  input {
    File ? java
    File picard

    File input_gvcf
    File input_gvcf_idx
    String filename_prefix

    Array[File] intervals

    File reference
    File reference_idx
    File reference_dict
    File dbsnp
    File dbsnp_idx

    String ? userString

    Array[String] modules = []
    Float memory = 16
    Int cpu = 16
  }

  Int jvm_memory = round(memory)
  String output_filename = filename_prefix + ".variant_calling_metrics.txt"

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{jvm_memory}g \
      -jar ~{default="picard" picard} CollectVariantCallingMetrics \
      INPUT=~{input_gvcf} \
      OUTPUT=~{filename_prefix} \
      SEQUENCE_DICTIONARY=~{reference_dict} \
      DBSNP=~{dbsnp} \
      THREAD_COUNT=~{cpu} \
      ~{userString} \
      GVCF_INPUT=true \
      INTERVALS=~{sep=" " intervals}
  }

  output {
    File gvcf_metrics = "~{output_filename}"
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
    dbsnp: "dbSNP VCF file. This is required by this Picard command."
    intervals: "An interval list file that contains the locations of the targets. Default value: null. This option must be specified at least 1 times."
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


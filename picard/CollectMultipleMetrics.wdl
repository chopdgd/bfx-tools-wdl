version 1.0

task CollectMultipleMetrics {
  input {
    File ? java
    File picard
    Array[String] programs = ["CollectAlignmentSummaryMetrics",
                              "CollectInsertSizeMetrics",
                              "CollectSequencingArtifactMetrics",
                              "CollectGcBiasMetrics",
                              "QualityScoreDistribution"]

    File input_bam
    File input_idx_bam
    String filename_prefix

    File reference
    File reference_idx
    File reference_dict

    String validation_stringency = "SILENT"
    String ? sort_order
    String ? userString

    Array[String] modules = []
    Float memory = 16
    Int cpu = 1
  }

  Int jvm_memory = round(memory)

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{jvm_memory}g \
      -jar ~{default="picard" picard} CollectMultipleMetrics \
      ~{sep=" " prefix("PROGRAM=", programs)} \
      ~{userString} \
      VALIDATION_STRINGENCY=~{validation_stringency} \
      REFERENCE_SEQUENCE=~{reference} \
      INPUT=~{input_bam} \
      ~{"ASSUME_SORT_ORDER=" + sort_order} \
      OUTPUT=~{filename_prefix};
  }

  output {
    File ? alignment_summary_metrics = "~{filename_prefix}" + ".alignment_summary_metrics"
    File ? bait_bias_detail_metrics = "~{filename_prefix}" + ".bait_bias_detail_metrics"
    File ? bait_bias_summary_metrics = "~{filename_prefix}" + ".bait_bias_summary_metrics"
    File ? base_distribution_metrics = "~{filename_prefix}" + ".base_distribution_by_cycle_metrics"
    File ? error_summary_metrics = "~{filename_prefix}" + ".error_summary_metrics"
    File ? gc_bias_detail_metrics = "~{filename_prefix}" + ".gc_bias.detail_metrics"
    File ? gc_bias_summary_metrics = "~{filename_prefix}" + ".gc_bias.summary_metrics"
    File ? insert_size_metrics = "~{filename_prefix}" + ".insert_size_metrics"
    File ? pre_adapter_detail_metrics = "~{filename_prefix}" + ".pre_adapter_detail_metrics"
    File ? pre_adapter_summary_metrics = "~{filename_prefix}" + ".pre_adapter_summary_metrics"
    File ? quality_by_cycle_metrics = "~{filename_prefix}" + ".quality_by_cycle_metrics"
    File ? quality_distribution_metrics = "~{filename_prefix}" + ".quality_distribution_metrics"
  }

  runtime {
    memory: jvm_memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    java: "Path to Java."
    picard: "Picard jar file."
    programs: "List of strings, one string for each metrics tool to run."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    reference_dict: "Reference sequence dictionary (.dict)."
    filename_prefix: "prefix for output files."
    input_bam: "Sorted BAM file."
    validation_stringency: "Validation stringency for all SAM files read by this program. Setting stringency to SILENT can improve performance when processing a BAM file in which variable-length data (read, qualities, tags) do not otherwise need to be decoded."
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

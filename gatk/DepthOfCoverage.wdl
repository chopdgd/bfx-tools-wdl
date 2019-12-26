version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://software.broadinstitute.org/gatk/
# Task Summary: Assess sequence coverage by a wide array of metrics, partitioned by sample, read group, or library
# Tool Name: GATK DepthOfCoverage
# Documentation: https://software.broadinstitute.org/gatk/documentation/tooldocs/3.8-0/org_broadinstitute_gatk_tools_walkers_coverage_DepthOfCoverage.php
# Example: https://software.broadinstitute.org/wdl/documentation/article?id=7615
# -------------------------------------------------------------------------------------------------


task DepthOfCoverage {
  input {
    File ? java
    File ? gatk
    File reference
    File reference_idx
    File reference_dict

    Array[File] intervals = []
    File ? gene_list

    String sample_id
    Array[File] bam_files
    Array[File] bam_idx_files

    Array[Int] summary_coverage_threshold = [15]
    String userString = "-omitBaseOutput -omitLocusTable"

    Array[String] modules = []
    Float memory = 4
    Int cpu = 1
  }

  Int jvm_memory = round(memory)
  Array[String] intervalOptions = prefix("--intervals ", intervals)
  String output_base_filename = sample_id + ".depthOfCoverage"

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{jvm_memory}g \
      -jar ~{default="gatk" gatk} \
      -T DepthOfCoverage \
      ~{userString} \
      -R ~{reference} \
      ~{"-geneList " + gene_list} \
      ~{sep=" " prefix("-ct ", summary_coverage_threshold)} \
      ~{sep=" " prefix("-I ", bam_files)} \
      ~{sep=" " intervalOptions} \
      -o ~{output_base_filename};
  }

  output {
    File sample_interval_statistics_file = "~{output_base_filename}" + ".sample_interval_statistics"
    File sample_statistics_file = "~{output_base_filename}" + ".sample_statistics"
    File sample_summary_file = "~{output_base_filename}" + ".sample_summary"
    File sample_interval_summary_file = "~{output_base_filename}" + ".sample_interval_summary"
    File ? sample_output_file = "~{output_base_filename}"
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
    intervals: "One or more genomic intervals over which to operate."
    gene_list: "Calculate coverage statistics over this list of genes"
    sample_id: "prefix for output files"
    bam_files: "List of Sorted and duplicate marked BAM file"
    bam_idx_files: "List of BAM file index (.bai)"
    summary_coverage_threshold: "Coverage threshold (in percent) for summarizing statistics"
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    gatk_version: "3.8"
    version: "0.2.0"
  }
}

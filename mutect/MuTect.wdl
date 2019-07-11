version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: MuTect v1
# Task Summary: Call somatic SNPs and indels via local re-assembly of haplotypes
# Tool Name: MuTect
# Archived MuTect: http://archive.broadinstitute.org/cancer/cga/mutect
# -------------------------------------------------------------------------------------------------


task MuTect {
  input {
    File ? java
    File ? mutect

    File reference
    File reference_idx
    File reference_dict

    Array[File] intervals = []
    File ? dbsnp
    File ? dbsnp_idx

    String sample_id
    File bam_file
    File bam_idx_file

    String ? userString

    Array[String] modules = []
    Float memory = 4
    Int cpu = 1
  }

  Array[String] intervalOptions = prefix("--intervals ", intervals)

  String vcf_filename = sample_id + "_MuTect.vcf"
  String vcf_idx_filename = sample_id + "_MuTect.vcf.idx"
  String stats_filename = sample_id + "_MuTect.call_stats.txt"
  String coverage_filename = sample_id + "_MuTect.coverage.wig.txt"

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{memory}g \
      -jar ~{mutect} \
      -T MuTect \
      ~{userString} \
      -R ~{reference} \
      ~{"--dbsnp " + dbsnp} \
      ~{sep=" " intervalOptions} \
      --input_file:tumor ~{bam_file} \
      --out ~{stats_filename} \
      --vcf ~{vcf_filename} \
      --coverage_file ~{coverage_filename};
  }

  output {
    File vcf_file = "~{vcf_filename}"
    File vcf_idx_file = "~{vcf_idx_filename}"
    File stats_file = "~{stats_filename}"
    File coverage_file = "~{coverage_filename}"
  }

  runtime {
    memory: memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    java: "Path to Java."
    mutect: "MuTect jar file."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    reference_dict: "Reference sequence dict (.dict)."
    dbsnp: "dbSNP VCF file."
    dbsnp_idx: "dbSNP VCF index file (.tbi)."
    intervals: "One or more genomic intervals over which to operate."
    sample_id: "sample id."
    bam_file: "Sorted BAM file."
    bam_idx_file: "Sorted BAM index file."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    mutect_version: "1.1.7"
    version: "0.1.0"
  }
}

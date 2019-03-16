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
    File mutect

    File reference
    File reference_idx
    File reference_dict

    File ? dbsnp
    File ? dbsnp_idx
    Array[File] intervals

    String sample_id
    File bam_file
    File bam_idx_file

    String ? userString

    Int ? memory
    Int ? cpu
  }

  String vcf_filename = sample_id + "_MuTect.vcf"
  String vcf_idx_filename = sample_id + "_MuTect.vcf.idx"
  String stats_filename = sample_id + "_MuTect.call_stats.txt"
  String coverage_filename = sample_id + "_MuTect.coverage.wig.txt"

  command {
    ${default="java" java} \
      -Xmx${default=4 memory}g \
      -jar ${mutect} \
      -T MuTect \
      ${userString} \
      -R ${reference} \
      ${"--dbsnp " + dbsnp} \
      ${sep=" " prefix("--intervals ", intervals)} \
      --input_file:tumor ${bam_file} \
      --out ${stats_filename} \
      --vcf ${vcf_filename} \
      --coverage_file ${coverage_filename}
  }

  output {
    File vcf_file = "${vcf_filename}"
    File vcf_idx_file = "${vcf_idx_filename}"
    File stats_file = "${stats_filename}"
    File coverage_file = "${coverage_filename}"
  }

  runtime {
    memory: select_first([memory, 4]) * 1.5 + " GB"
    cpu: select_first([cpu, 1])
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

version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: MuTect v1
# Task Summary: Call somatic SNPs and indels via local re-assembly of haplotypes
# Tool Name: MuTect
# Archived MuTect: http://archive.broadinstitute.org/cancer/cga/mutect
# -------------------------------------------------------------------------------------------------


task MuTect2 {
  input {
    File ? gatk4

    File reference
    File ? reference_idx
    File reference_dict

    File intervals
    File ? dbsnp
    File ? dbsnp_idx

    String sample_id
    File bam_file
    File ? bam_idx_file

    String ? userString

    Array[String] modules = []
    Float memory = 12
    Int cpu = 1

    String vcf_filename = sample_id + "_MuTect.vcf"
    String vcf_idx_filename = sample_id + "_MuTect.vcf.idx"
    String stats_filename = sample_id + "_MuTect.vcf.stats"
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{gatk4} Mutect2 \
      -R ~{reference} \
      -I ~{bam_file} \
      -L ~{intervals} \
      -O ~{vcf_filename}
  }

  output {
    File vcf_file = "~{vcf_filename}"
    File vcf_idx_file = "~{vcf_idx_filename}"
    File stats_file = "~{stats_filename}"
  }

  runtime {
    memory: memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    gatk4: "Path to gatk (v4 and up)."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    reference_dict: "Reference sequence dict (.dict)."
    intervals: "One or more genomic intervals over which to operate."
    sample_id: "sample id."
    bam_file: "Sorted BAM file."
    bam_idx_file: "Sorted BAM index file."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "K Cao"
    email: "caok@chop.edu"
    gatk_version: "4.2.6"
    mutect_version: "2.0"
    version: "0.1.0"
  }
}

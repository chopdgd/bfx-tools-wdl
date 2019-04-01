version 1.0
# -------------------------------------------------------------------------------------------------
# VerifyBamId: https://genome.sph.umich.edu/wiki/VerifyBamID
# Task Summary: detect sample contamination and swaps.
# Tool Name: VerifyBamId
# Documentation: https://genome.sph.umich.edu/wiki/VerifyBamID
# -------------------------------------------------------------------------------------------------


task VerifyBamId {
  input {
    File ? verifybamid

    String sample_id
    File bam_file
    File bam_idx_file

    File omni_vcf
    File omni_vcf_idx
    String userString = "--maxDepth 1000 --ignoreRG --verbose --precise --chip-none"

    Array[String] modules = []
    Int memory = 8
    Int cpu = 1
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ${sep=' ' modules}; do
      module load $MODULE
    done;

    ${default="verifybamid" verifybamid} \
      --vcf ${omni_vcf} \
      --bam ${bam_file} \
      --out ${sample_id} \
      ${userString};
  }

  output {
    File freemix_file = "${sample_id}" + ".selfSM"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    verifybamid: "VerifyBamID executable."
    sample_id: "prefix for output files"
    bam_file: "BAM file."
    bam_idx_file: "BAM file index (.bai)."
    omni_vcf: "OMNI VCF."
    omni_vcf_idx: "OMNI VCF index (.tbi)."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    verifybamid_version: "1.1.3"
    version: "0.1.0"
  }
}

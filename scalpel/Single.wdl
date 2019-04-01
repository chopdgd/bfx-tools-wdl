version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://scalpel.sourceforge.net/
# Task Summary: Scalpel is a software package for detecting INDELs (INsertions and DELetions) mutations in a reference genome which has been sequenced with next-generation sequencing technology (e.g., Illumina).
# Tool Name: Scalpel
# Documentation: http://scalpel.sourceforge.net/
# NOTE: Scalpel needs to be a string because of Perl modules that it depends on found in its directory
# -------------------------------------------------------------------------------------------------


task Single {
  input {
    # NOTE: The reason for making this a string is because we want to avoid linking the file.
    # It required a bunch of Perl modules found alongside the script
    String ? scalpel

    File reference
    File reference_idx
    File intervals

    String sample_id
    File bam_file
    File bam_idx_file

    String userString = "--mapscore 15 --intarget --format vcf"

    Array[String] modules = []
    Int memory = 4
    Int cpu = 1
  }

  String output_filename = sample_id + "/variants.indel.vcf"

  command {
    set -Eeuxo pipefail;

    for MODULE in ${sep=' ' modules}; do
        module load $MODULE
    done;

    ${default="scalpel" scalpel} --single \
      --ref ${reference} \
      --bam ${bam_file} \
      --bed ${intervals} \
      --numprocs ${cpu} \
      ${userString} \
      --dir ${sample_id};
  }

  output {
    File vcf_file = "${output_filename}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    scalpel: "Scalpel exe file."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    intervals: "One or more genomic intervals over which to operate."
    bam_file: "Sorted BAM file."
    bam_idx_file: "Sorted BAM file index."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    scalpel_version: "0.5.2"
    version: "0.1.0"
  }
}

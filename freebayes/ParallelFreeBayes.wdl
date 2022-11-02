version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: FreeBayes
# Task Summary: FreeBayes is a Bayesian genetic variant detector
# Tool Name: FreeBayes
# Documentation: https://github.com/ekg/freebayes
# -------------------------------------------------------------------------------------------------


task ParallelFreeBayes {
  input {
    File ? freebayes
    File vcffirstheader
    File vcfuniq
    File vcfstreamsort

    File reference
    File reference_idx

    File intervals

    String sample_id
    File bam_file
    File bam_idx_file

    String userString = "-4 -q 15 -F 0.03"

    Array[String] modules = []
    Float memory = 1
    Int cpu = 24
    String output_filename = "freebayes.vcf"
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    split -l 40 ~{intervals} regions_split_;
    (find . -name "regions_split_*" | parallel -k -j ~{cpu} \
      ~{default="freebayes" freebayes} \
      ~{userString} \
      -f ~{reference} \
      ~{bam_file} \
      -t ) | ~{vcffirstheader} \
      | ~{vcfstreamsort} \
      | ~{vcfuniq} > ~{output_filename};
    rm -f regions_split_*;

  }

  output {
    File vcf_file = "~{output_filename}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    freebayes: "freebayes executable."
    vcffirstheader: "vcffirstheader scripts from vcflib"
    vcfuniq: "vcfuniq from vcflib to get unique vcf"
    vcfstreamsort: "vcfstreamsort from vcflib"
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    intervals: "One or more genomic intervals over which to operate."
    bam_file: "Sorted BAM file."
    bam_idx_file: "Sorted BAM index file."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "fuw@chop.edu"
    email: "fuw@chop.edu"
    freebayes_version: "1.0.1"
    version: "0.1.0"
  }
}

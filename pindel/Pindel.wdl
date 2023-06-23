version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://gmt.genome.wustl.edu/packages/pindel/
# Task Summary: Pindel can detect breakpoints of large deletions, medium sized insertions, inversions, tandem duplications and other structural variants at single-based resolution from next-gen sequence data
# Tool Name: Pindel
# Documentation: http://gmt.genome.wustl.edu/packages/pindel/user-manual.html
# -------------------------------------------------------------------------------------------------


task Pindel {
  input {
    File ? pindel

    File reference
    File reference_idx

    File ? intervals

    String sample_id
    File bam_file
    File bam_idx_file

    Int sliding_window = 300
    String userString = "-t"

    Array[String] modules = []
    Float memory = 12
    Int cpu = 1
  }

  command {
    set -Eeuxo pipefail;

    echo -e ~{bam_file}"\t"~{sliding_window}"\t"~{sample_id} > config;

    pindel \
      ~{userString} \
      ~{"-j " + intervals} \
      -f ~{reference} \
      -i config \
      -o ~{sample_id};
  }

  output {
    File deletion_file = "~{sample_id}" + "_D"
    File short_insertion_file = "~{sample_id}" + "_SI"
    File inversion_file = "~{sample_id}" + "_INV"
    File tandem_duplication_file = "~{sample_id}" + "_TD"
    File large_insertion_file = "~{sample_id}" + "_LI"
    File unassigned_breakpoints_file = "~{sample_id}" + "_BP"
    File CloseEndMapped_file = "~{sample_id}" + "_CloseEndMapped"
    File INT_file = "~{sample_id}" + "_INT_final"
    File RP_file = "~{sample_id}" + "_RP"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
    singularity: true
    image: pindel
  }

  parameter_meta {
    pindel: "pindel executable."
    reference: "reference file."
    reference_idx: "reference idx."
    intervals: "One or more genomic intervals over which to operate."
    sample_id: "sample id."
    bam_file: "BAM file."
    bam_idx_file: "BAM index file."
    sliding_window: "Sliding window to use in Pindel."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    pindel_version: "0.2.5"
    version: "0.1.0"
  }
}

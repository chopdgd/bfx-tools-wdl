version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: BedTools Intersect
# Task Summary: detect overlaps between two sets of genomic features
# Tool Name: bedtools intersect
# Documentation: https://bedtools.readthedocs.io/en/latest/content/tools/intersect.html
# -------------------------------------------------------------------------------------------------


task Intersect {
  input {
    File ? bedtools

    File bed_a
    Array[File] beds

    String userString = "-wao"

    Array[String] modules = []
    Float memory = 1
    Int cpu = 1

    String output_filename = basename(bed_a, ".bed") + '.intersect.bed'
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="bedtools" bedtools} \
      intersect \
      -a ~{bed_a} \
      -b ~{sep=', ' beds} \
      ~{userString} > ~{output_filename}
  }

  output {
    File intersect_bed = "~{output_filename}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    bedtools: "bedtools executable."
    bed_a: "the BED in which all features are compared"
    beds: "the BED(s) to check for overlapping features with bed_a"
    userString: "An optional parameter which allows the user to specify additions to the command line at run time"
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    bedtools_version: "2.27.0"
    version: "0.1.0"
  }
}

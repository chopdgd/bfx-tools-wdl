version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: BedTools Intersect
# Task Summary: detect overlaps between two sets of genomic features
# Tool Name: bedtools intersect
# Documentation: https://bedtools.readthedocs.io/en/latest/content/tools/intersect.html
# -------------------------------------------------------------------------------------------------


task BamToFastQ {
  input {
    File ? bedtools

    File vcf_a
    Array[File] vcfs

    String userString = "-wao"

    Array[String] modules = []
    Int memory = 1
    Int cpu = 1
  }

  String output_filename = basename(vcf_a, ".vcf") + '.intersect.vcf'

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="bedtools" bedtools} \
      intersect \
      -a ~{vcf_a} \
      -b ~{sep=', ' vcfs} \
      ~{userString} > ~{output_filename}
  }

  output {
    File intersect_vcf = "~{output_filename}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    bedtools: "bedtools executable."
    vcf_a: "the VCF in which all all features are compared"
    vcfs: "the VCF(s) to check for overlapping features with vcf_a"
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

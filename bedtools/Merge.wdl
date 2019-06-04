version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: BedTools Merge
# Task Summary: combines overlapping features in a file into a single feature which spans all of the combined features.
# Tool Name: bedtools merge
# Documentation: https://bedtools.readthedocs.io/en/latest/content/tools/merge.html
# -------------------------------------------------------------------------------------------------


task Merge {
  input {
    File ? bedtools

    File vcf
    String columns = "4,5,6,7,8,9,10,11"
    String operation = "collapse"

    String ? userString

    Array[String] modules = []
    Int memory = 1
    Int cpu = 1
  }

  String output_filename = basename(vcf, ".vcf") + '.merged.vcf'

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="bedtools" bedtools} \
      merge -i \
      ~{vcf} \
      -c ~{columns} \
      -o ~{operation} \
      ~{userString} > ~{output_filename}
  }

  output {
    File merged_vcf = "~{output_filename}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    bedtools: "bedtools executable."
    vcf: "the VCF in which all features are to be merged"
    columns: "comma separated list (bedtools requirement) to operate upon)"
    operation: "the type of merge to be preformed; 'collapse' keeps duplicates"
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

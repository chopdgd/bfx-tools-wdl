version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://gmt.genome.wustl.edu/packages/pindel/
# Task Summary: Pindel can detect breakpoints of large deletions, medium sized insertions, inversions, tandem duplications and other structural variants at single-based resolution from next-gen sequence data
# Tool Name: Pindel
# Documentation: http://gmt.genome.wustl.edu/packages/pindel/user-manual.html
# -------------------------------------------------------------------------------------------------


task Pindel2Vcf {
  input {
    File ? pindel2vcf

    File reference
    File reference_idx
    String reference_version =  "1000GenomesPilot-NCBI37"
    String reference_date = "20101123"

    File input_file

    String ? userString

    Array[String] modules = []
    Int memory = 8
    Int cpu = 1
  }

  String temp_filename = basename(input_file) + '_merged_pindel_files'

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    cp ~{input_file} ~{temp_filename};

    ~{default="pindel2vcf" pindel2vcf} \
      ~{userString} \
      -r ~{reference} \
      -R ~{reference_version} \
      -d ~{reference_date} \
      -p ~{temp_filename};
  }

  output {
    File vcf_file = "~{temp_filename}" + ".vcf"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    pindel2vcf: "pindel2vcf executable."
    reference: "reference file."
    reference_idx: "reference idx."
    reference_version: "The name and version of the reference genome."
    reference_date: "The date of the version of the reference genome used."
    input_file: "output from pindel."
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

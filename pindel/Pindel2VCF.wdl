version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://gmt.genome.wustl.edu/packages/pindel/
# Task Summary: Pindel can detect breakpoints of large deletions, medium sized insertions, inversions, tandem duplications and other structural variants at single-based resolution from next-gen sequence data
# Tool Name: Pindel
# Documentation: http://gmt.genome.wustl.edu/packages/pindel/user-manual.html
# -------------------------------------------------------------------------------------------------

task Pindel2Vcf {
  input {
    File pindel2vcf

    File reference
    File reference_idx
    File ? reference_version
    String ? reference_date

    File input_file

    String ? userString

    Int ? memory
    Int ? cpu
  }

  String temp_filename = basename(input_file)

  command {
    set -Eeuxo pipefail;
    cp ${input_file} ${temp_filename};

    ${pindel2vcf} ${userString} \
      -r ${reference} \
      -R ${default="1000GenomesPilot-NCBI37" reference_version} \
      -d ${default="20101123" reference_date} \
      -p ${temp_filename};
  }

  output {
    File vcf_file = "${temp_filename}" + ".vcf"
  }

  runtime {
    memory: select_first([memory, 8]) + " GB"
    cpu: select_first([cpu, 1])
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

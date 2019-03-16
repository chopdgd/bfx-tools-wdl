version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: Vt
# Task Summary: Decompose multiallelic variants in a VCF
# Tool Name: Vt
# Documentation: https://genome.sph.umich.edu/wiki/Vt#Decompose_biallelic_block_substitutions
# -------------------------------------------------------------------------------------------------


task DecomposeBlockSubstitutions {
  input {
    File vt

    File input_file
    File ? input_idx_file

    Int ? memory
    Int ? cpu
  }

  String output_filename = basename(vcf_file) + ".decomposed.blocksub.vcf"

  command {
    ${default="vt" vt} decompose_blocksub ${input_file} -o ${output_filename};
  }

  output {
    File vcf_file = "${output_filename}"
  }

  runtime {
    memory: select_first([memory, 4]) + " GB"
    cpu: select_first([cpu, 1])
  }

  parameter_meta {
    vt: "Vt executable."
    input_file: "VCF file."
    input_idx_file: "VCF file index (.tbi)."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    vt_version: "v0.5772-60f436c3"
    version: "0.1.0"
  }
}

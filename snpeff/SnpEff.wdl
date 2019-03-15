version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: SnpEff
# Task Summary: Annotate variants in a VCF
# Tool Name: eff/ann
# Documentation: http://snpeff.sourceforge.net/SnpEff_manual.html
# -------------------------------------------------------------------------------------------------

task SnpEff {
  input {
    File ? java
    File snpeff
    File config

    File filename_prefix
    File input_file
    File ? input_idx_file

    String dataDir
    String ? reference_version
    String ? userString

    Int ? memory
    Int ? cpu
  }

  String output_filename = filename_prefix + '.snpeff.vcf'

    command {
      ${default="java" java} \
        -Xmx${default=4 memory}g \
        -jar ${snpeff} eff \
        ${userString} \
        -c ${config} \
        -dataDir ${dataDir} \
        ${default="hg19" reference_version} \
        ${vcf_file} > ${output_filename}
  }

  output {
    File vcf_file = "${output_filename}"
  }

  runtime {
    memory: select_first([memory, 4]) * 1.5 + " GB"
    cpu: select_first([cpu, 1])
  }

  parameter_meta {
    java: "Path to Java."
    snpeff: "SnpEff jar file."
    config: "Specify config file."
    input_file: "VCF file to annotate."
    input_idx_file: "VCF file index (.tbi)"
    dataDir: "Override data_dir parameter from config file."
    reference_version: "Version of genome to use."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    snpeff_version: "4.3q"
    version: "0.1.0"
  }
}

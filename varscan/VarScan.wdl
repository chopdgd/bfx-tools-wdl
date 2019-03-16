version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://massgenomics.org/varscan
# Task Summary: VarScan is a tool that detects variants (SNPs and indels) in next-generation sequencing data
# Tool Name: VarScan
# Documentation: https://github.com/dkoboldt/varscan
# -------------------------------------------------------------------------------------------------


task MPileup2CNS {
  input {
    File ? java
    File varscan

    String sample_id
    File mpileup

    String ? userString

    Int ? memory
    Int ? cpu
  }

  String output_filename = sample_id + '.varscan.vcf'

  command {
    ${default="java" java} \
      -Xmx${default=4 memory}g \
      -jar ${varscan} mpileup2cns \
      ${mpileup} \
      ${default="--min_var-freq 0.03 --strand-filter 1" userString} \
      --variants --output-vcf 1 > ${output_filename};
  }

  output {
    File vcf_file = "${output_filename}"
  }

  runtime {
    memory: select_first([memory, 4]) * 2 + " GB"
    cpu: select_first([cpu, 1])
  }

  parameter_meta {
    java: "Path to Java."
    varscan: "varscan JAR file."
    sample_id: "sample id."
    mpileup: "Samtools mpileup file"
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    varscan_version: "2.3.9"
    version: "0.1.0"
  }
}

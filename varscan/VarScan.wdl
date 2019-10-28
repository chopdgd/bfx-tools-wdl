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
    File ? varscan

    String sample_id
    File mpileup

    String userString = "--min-var-freq 0.03 --strand-filter 1"

    Array[String] modules = []
    Float memory = 4
    Int cpu = 1

    String output_filename = sample_id + '.varscan.vcf'
  }

  Int jvm_memory = round(memory)

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{jvm_memory}g \
      -jar ~{default="varscan" varscan} mpileup2cns \
      ~{mpileup} \
      ~{userString} \
      --variants --output-vcf 1 > ~{output_filename};
  }

  output {
    File vcf_file = "~{output_filename}"
  }

  runtime {
    memory: memory * 1.5 + " GB"
    cpu: cpu
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
    version: "0.2.0"
  }
}

version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: SnpSift
# Task Summary: Annotate variants in a VCF
# Tool Name: annotate/dbnsfp
# Documentation:
#  * http://snpeff.sourceforge.net/SnpSift.html#annotate
#  * http://snpeff.sourceforge.net/SnpSift.html#dbNSFP
# -------------------------------------------------------------------------------------------------


task SnpSift {
  input {
    File ? java
    File ? snpsift
    File config

    String filename_prefix
    File input_file
    File ? input_idx_file

    File database
    File ? database_idx

    String mode = "annotate"
    String ? userString

    Array[String] modules = []
    Float memory = 4
    Int cpu = 1
  }

  Int jvm_memory = round(memory)
  String database_prefix = if mode == "dbnsfp" then "-db" else ""
  String output_filename = filename_prefix + '.snpsift.vcf'

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{jvm_memory}g \
      -jar ~{default="snpsift" snpsift} \
      ~{mode} \
      ~{userString} \
      -c ~{config} \
      ~{database_prefix} ~{database} \
      ~{input_file} > ~{output_filename};
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
    snpsift: "SnpSift jar file."
    config: "Specify config file."
    input_file: "VCF file to annotate."
    input_idx_file: "VCF file index (.tbi)"
    database: "File to use as annotations database."
    database_idx: "Annotations database index file."
    mode: "Annotation mode. Annotate or dbNSFP."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    snpsift_version: "4.3q"
    version: "0.1.0"
  }
}

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
    File snpsift
    File config

    String filename_prefix
    File input_file
    File ? input_idx_file

    File database
    File ? database_idx

    String ? mode
    String database_prefix = if mode == "dbnsfp" then "-db" else ""
    String ? userString

    Int ? memory
    Int ? cpu
  }

  String output_filename = filename_prefix + '.snpsift.vcf'

  command {
    ${default="java" java} \
      -Xmx${default=4 memory}g \
      -jar ${snpsift} \
      ${default="annotate" mode} \
      ${default="" userString} \
      -c ${config} \
      ${database_prefix} ${database} \
      ${input_file} > ${output_filename}
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

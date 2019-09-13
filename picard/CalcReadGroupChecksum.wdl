version 1.0

task CalcReadGroupChecksum {
  input {
    File ? java
    File picard

    File input_bam
    File input_idx_bam
    String filename_prefix

    String ? userString

    Array[String] modules = []
    Float memory = 16
    Int cpu = 1
  }

  Int jvm_memory = round(memory)
  String output_filename = filename_prefix + ".read_group_md5"

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{jvm_memory}g \
      -jar ~{default="picard" picard} CalculateReadGroupChecksum \
      INPUT=~{input_bam} \
      ~{userString} \
      OUTPUT=~{output_filename};
 }

  output {
    File md5_file = "~{output_filename}"
  }

  runtime {
    memory: jvm_memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    java: "Path to Java."
    picard: "Picard jar file."
    input_bam: "BAM file to generate checksum for"
    filename_prefix: "prefix for output files."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    picard_version: "2.19.0"
    version: "0.1.0"
  }
}

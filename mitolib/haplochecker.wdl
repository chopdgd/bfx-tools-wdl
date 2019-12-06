version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/haansi/mitolib/
# Tool Name: haplochecker
# Documentation: https://github.com/haansi/mitolib
# -------------------------------------------------------------------------------------------------


task ContaminationCheck {
  input {

    File ? java
    File ? mitolib
    File ? reference

    File input_bam_file
    String sample_name
    String userString = "--VAF 0.01 --QUAL 10 --MAPQ 20"

    Array[String] modules = []
    Float memory = 8
    Int cpu = 1

    String output_filename = sample_name + "/" + sample_name + ".sorted.contamination.txt"
  }

  Int jvm_memory = round(memory)

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{jvm_memory}g \
      -jar ~{default="mitolib" mitolib} haplochecker \
      --ref ~{reference} \
      ~{userString} \
      "--in" ~{input_bam_file} \
      "--out" ~{sample_name};
  }

  output {
    File output_file = "~{output_filename}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    java: "java executable."
    reference: "Reference sequence file."
    input_bam_file: "Input bam file to process."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Pushkala Jayaraman"
    email: "jayaramanp@email.chop.edu"
    mitolib_version: "0.1.2"
    version: "0.1.0"
  }
}

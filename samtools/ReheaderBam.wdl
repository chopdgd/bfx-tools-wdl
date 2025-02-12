version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://www.htslib.org/
# Tool Name: Samtools
# Documentation: http://www.htslib.org/doc/samtools.html
# -------------------------------------------------------------------------------------------------


task Reheader {
  input {
    File ? samtools
    File ? reference

    File input_file
    String output_filename
    String command
    String ? reheaderUserString
    String ? reindexUserString
    Boolean isCram = false
    String output_filename = "reheader_output." + if isCram then "cram" else "bam"
    String output_idx_filename = output_filename + if isCram then ".crai" else ".bai"

    Array[String] modules = []
    Float memory = 12
    Int cpu = 1
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="samtools" samtools} reheader \
      ~{"--reference " + reference} \
      ~{reheaderUserString} \
      ${input_file} > ${output_filename};

    ~{default="samtools" samtools} index \
      ~{"--reference " + reference} \
      ~{reindexUserString} \
      ${output_filename} > ${output_idx_filename};
  }

  output {
    File output_file = output_filename
    File output_idx_file = output_idx_filename
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    samtools: "Samtools executable."
    reference: "Reference sequence file."
    input_file: "Input file to process."
    command: "Samtools tool to use (i.e. index, sort, etc)."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    samtools_version: "1.9"
    version: "0.1.0"
  }
}
version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://www.htslib.org/
# Tool Name: Samtools
# Documentation: http://www.htslib.org/doc/samtools.html
# -------------------------------------------------------------------------------------------------


task BAMIndex {
  input {
    File ? samtools

    String ? userString
    File input_file

    Array[String] modules = []
    Int memory = 4
    Int cpu = 1
  }

  String output_file = input_file + '.bai'

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="samtools" samtools} index \
      ~{"-@ " + cpu} \
      ~{userString} \
      ~{input_file} > ~{output_file};
  }

  output {
    File output_idx_file = "${output_file}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    samtools: "Samtools executable."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    input_file: "Input file to process."
    modules: "Modules to load when task is called; modules must be compatible with the platform the task runs on."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    samtools_version: "1.9"
    version: "0.1.0"
  }
}

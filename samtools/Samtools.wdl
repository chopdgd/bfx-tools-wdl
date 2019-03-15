version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://www.htslib.org/
# Tool Name: Samtools
# Documentation: http://www.htslib.org/doc/samtools.html
# -------------------------------------------------------------------------------------------------

task Samtools {
  input {
    File samtools
    File ? reference

    File input_file
    String command
    String ? userString

    Int ? memory
    Int ? cpu
  }

  command {
    ${samtools} \
      ${command} \
      ${"--reference " + reference} \
      ${"-@ " + cpu} \
      ${userString} \
      ${input_file}
  }

  output {
    File output_file = stdout()
  }

  runtime {
    memory: select_first([memory, 4]) + " GB"
    cpu: select_first([cpu, 1])
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

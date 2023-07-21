version 1.0


task CombineFastQ {
  input {
    String fastq
    Array[String] additional_fastq

    Array[String] modules = []
    Float memory = 12
    Int cpu = 1

    String output_filename = basename(fastq)
  }

  Int files = length(additional_fastq)

  command <<<
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    if [[ "~{files}" == "0" ]]
    then
      cat ~{fastq} > ~{output_filename}
    else
      cat ~{fastq} ~{sep=" " additional_fastq} > ~{output_filename}
    fi
  >>>

  output {
    File output_file = "~{output_filename}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }
}

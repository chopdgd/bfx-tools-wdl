version 1.0


task CombineFastQ {
  input {
    File fastq
    Array[File] additional_fastq

    Array[String] modules = []
    Float memory = 1
    Int cpu = 1
  }

  Int files = length(additional_fastq)
  String output_filename = basename(fastq)

  command <<<
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    if [[ "~{files}" == "0" ]]
    then
      ln -s ~{fastq} ~{output_filename}
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

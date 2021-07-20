version 1.0


task UnzipPetaFastQ {
  input {
    File fastq
    Array[String] modules = ["petagene"]
    Float memory = 16
    Int cpu = 1

    String output_filename = basename(fastq)
  }


  command <<<
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    fastq_file="~{fastq}"
    fasterq_file=${fastq_file/fastq.gz/fasterq}
    if [[ -f $fasterq_file ]]
    then
      petasuite -d --md5match -D $(pwd) $fasterq_file
    else
      ln -s $fastq_file ~{output_filename}
    fi
  >>>

  output {
    File UnzipPetaFastQ = "~{output_filename}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }
}

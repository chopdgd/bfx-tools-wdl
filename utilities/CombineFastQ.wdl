version 1.0


task CombineFastQ {
  input {
    File fastq
    Array[File] additional_fastq

  }

  Int files = length(additional_fastq)
  String output_filename = basename(fastq)

  command <<<
    if [[ "${files}" == "0" ]]
    then
      ln -s ${fastq} ${output_filename}
    else
      cat ${fastq} ${sep=" " additional_fastq} > ${output_filename}
    fi
  >>>

  output {
    File output_file = "${output_filename}"
  }
}

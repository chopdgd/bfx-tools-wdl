version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://www.novocraft.com/products/novoalign/
# Task Summary: Align FASTQ files to reference genome using NovoAlign
# Tool Name: NovoAlign
# Documentation: http://www.novocraft.com/documentation/novoalign-2/
# -------------------------------------------------------------------------------------------------


task NovoAlign {
  input {
    File novoalign
    File novoalign_license
    File reference

    String sample_id
    File fastq_1
    File fastq_2

    String ? output_format
    String ? library
    String ? platform
    String ? platform_unit

    String ? userString

    Int ? memory
    Int ? cpu
    Boolean ? debug
  }

  command {
    ${novoalign} \
      -d ${reference} \
      -f ${fastq_1} ${fastq_2} \
      -c ${default=16 cpu} \
      -o ${default="SAM" output_format} \
      ${default="-i PE 240,150 -r All 5 -R 60 -t 15,2 -H 20 99999 --hlimit 7 --trim3HP -p 5,20 -k" userString} \
      ${default=false true="-# 50000" false="" debug} \
      "@RG\\tID:${sample_id}\\tPU:${default="PU" platform_unit}\\tLB:${default="LB" library}\\tPL:${default="PL" platform}\\tSM:${sample_id}"
  }

  output {
    File metrics_file = stderr()
    File sam_file = stdout()
  }

  runtime {
    memory: select_first([memory, 1]) + " GB"
    cpu: select_first([cpu, 16])
  }

  parameter_meta {
    novoalign: "NovoAlign executable."
    novoalign_license: "NovoAlign license."
    reference: "Reference sequence file index with NovoIndex."
    sample_id: "Sample ID to use in SAM tag."
    fastq_1: "FASTQ Files left reads."
    fastq_2: "FASTQ Files right reads."
    output_format: "Output format of alignment."
    library: "LB parameter for readgroup."
    platform: "PL parameter for readgroup."
    platform_unit: "PU parameter for readgroup."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
    debug: "Should only map 50000 reads to test."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    novoalign_version: "3.06.01"
    version: "0.1.0"
  }
}

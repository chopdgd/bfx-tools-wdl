version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/BoevaLab/FREEC
# Task Summary: Copy number and genotype annotation from whole genome and whole exome sequencing data
# Tool Name: Control-FREEC
# Documentation: http://boevalab.inf.ethz.ch/FREEC/tutorial.html
# Example Config File: https://github.com/BoevaLab/FREEC/blob/master/data/config_WGS.txt
# -------------------------------------------------------------------------------------------------


task ControlFREEC {
  input {
    File control_freec
    File sambamba
    File samtools

    String chr_len_files_directory
    Boolean is_tumor_normal = "false"

    File tumor_input
    File tumor_input_idx
    File ? normal_input
    File ? normal_input_idx

    File reference
    File reference_idx

    Int ploidy = 2
    Float coefficient_of_variation = 0.062
    String input_format = "BAM"
    String mate_orientation = "0"

    String ? userString

    Array[String] modules = []
    Float memory = 16
    Int cpu = 4
  }

  Int pymem = round(memory)

  command <<<
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    touch config.txt

    GENERAL='[general]
    chrLenFile = ~{reference_idx}
    chrFiles = ~{chr_len_files_directory}
    ploidy = ~{ploidy}
    maxThreads = ~{cpu}
    coefficientOfVariation = ~{coefficient_of_variation}
    #sambamba = ~{sambamba}
    #samtools = ~{samtools}'

    echo "$GENERAL" >> config.txt

    SAMPLE='[sample]
    mateFile = ~{tumor_input}
    inputFormat = ~{input_format}
    mateOrientation = ~{mate_orientation}'

    echo "$SAMPLE" >> config.txt

    if [ ~{is_tumor_normal} == "true" ]; then
      CONTROL='[control]
      mateFile = ~{normal_input}
      inputFormat = ~{input_format}
      mateOrientation = ~{mate_orientation}'
      echo "$CONTROL" >> config.txt
    fi

    ~{control_freec} -conf config.txt
  >>>

  output {
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    control_freec: "Path to Control-FREEC binary"
    chr_len_files_directory: "Path to directory with ONLY files that contain chr, one per chr"
    reference: "FASTA reference file"
    reference_idx: "FASTA reference fil index (.fai)"
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    freec_verison: "11.5.0"
    version: "0.1.0"
  }
}

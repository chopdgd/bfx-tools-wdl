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

    # NOTE: this is a String and not
    #       a Boolean because it will
    #       by used in the bash script
    String is_tumor_normal = "false"
    String chr_len_files_directory

    File tumor_input
    File tumor_input_idx
    File ? normal_input
    File ? normal_input_idx

    File reference
    File reference_idx

    Int ploidy = 2
    Float coefficient_of_variation = 0.062
    String input_format = "BAM"
    String mate_orientation = "FR"

    String ? userString

    Array[String] modules = []
    Float memory = 16
    Int cpu = 4
  }

  String copynumber_filename = basename(tumor_input, ".bam") + ".bam_sample.cpn"
  String ratio_filename = basename(tumor_input, ".bam") + ".bam_ratio.txt"
  String cnv_filename = basename(tumor_input, ".bam") + ".bam_CNVS"
  String bam_info_filename = basename(tumor_input, ".bam") + ".bam_info.txt"

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
    sambamba = ~{sambamba}
    samtools = ~{samtools}'

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
    File copynumber_file = "~{copynumber_filename}"
    File ratio_file = "~{ratio_filename}"
    File cnv_file = "~{cnv_filename}"
    File bam_info_file = "~{bam_info_filename}"
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

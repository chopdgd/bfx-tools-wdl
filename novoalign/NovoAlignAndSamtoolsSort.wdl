version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://www.novocraft.com/products/novoalign/
# Task Summary: Align FASTQ files to reference genome using NovoAlign
# Tool Name: NovoAlign and Samtools
# Documentation: http://www.novocraft.com/documentation/novoalign-2/
# -------------------------------------------------------------------------------------------------


task NovoAlignAndSamtoolsSort {
  input {
    File ? novoalign
    File novoalign_license
    File ? samtools

    File reference
    File reference_idx
    File reference_novoindex

    String sample_id
    File fastq_1
    File fastq_2

    String output_format = "SAM"
    String library = "LB"
    String platform = "PL"
    String platform_unit = "PU"

    String userString = "-i PE 240,150 -r All 5 -R 60 -t 15,2 -H 20 99999 --hlimit 7 --trim3HP -p 5,20 -k"
    String ? Samtools_view_parameters
    String ? Samtools_sort_parameters

    Array[String] modules = []
    Float memory = 2.5
    Int cpu = 16
    Boolean debug = false
  }

  String output_filename = sample_id + ".sorted.bam"
  String output_idx_filename = sample_id + ".sorted.bam.bai"
  String output_alignment_stats = sample_id + ".alignment.stats"

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    cp ~{novoalign_license} .;

    ~{default="novoalign" novoalign} \
      -d ~{reference_novoindex} \
      ~{true="-# 50000" false="" debug} \
      -f ~{fastq_1} ~{fastq_2} \
      ~{userString} \
      -c ~{cpu} \
      -o ~{output_format} \
      "@RG\\tID:~{sample_id}\\tPU:~{platform_unit}\\tLB:~{library}\\tPL:~{platform}\\tSM:~{sample_id}" | \
    ~{default="samtools" samtools} view \
      -b \
      ~{Samtools_view_parameters} \
      --reference ~{reference} \
      ~{"-@ " + cpu} \
      - | \
    ~{default="samtools" samtools} sort \
      ~{Samtools_sort_parameters} \
      -O BAM \
      --reference ~{reference} \
      ~{"-@ " + cpu} \
      - \
      -o ~{output_filename};

    ~{default="samtools" samtools} index ~{"-@ " + cpu} ~{output_filename} ~{output_idx_filename};

    cp "stderr" ~{output_alignment_stats};
  }

  output {
    File metrics_file = "~{output_alignment_stats}"
    File bam_file = "~{output_filename}"
    File bam_idx_file = "~{output_idx_filename}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    novoalign: "NovoAlign executable."
    novoalign_license: "NovoAlign license."
    samtools: "Samtools executable."
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

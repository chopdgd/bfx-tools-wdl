version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://research-pub.gene.com/gmap/
# Task Summary: Align FASTQ files to a circular-aware reference genome using GMAP-GSNAP
# Tool Name: gsnap
# Documentation: http://research-pub.gene.com/gmap/
# -------------------------------------------------------------------------------------------------


task Gsnap {
  input {
    File ? gsnap
    File ? circ_reference
    String reference_dir
    String sample_id
    File fastq_1
    File fastq_2

    String read_group_id = "~{sample_id}"
    String read_group_name = "~{sample_id}"
    String read_group_library = "Illumina"
    String read_group_platform = "HiSeq"
    String platform_unit = "PU"

    String userString = "--gunzip --format=sam --nofails --pairmax-dna=500 --query-unk-mismatch=1 -n 1 -O -t 4 "

    Array[String] modules = []
    Int memory = 1
    Int cpu = 16
    Boolean debug = false
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="gsnap" gsnap} \
      -D ~{reference_dir} \
      -d ~{default="chrMc" circ_reference}
      ~{userString} \
      ~{fastq_1} ~{fastq_2};
  }

  output {
    File sam_file = stdout()
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    gsnap: "gsnap executable."
    reference_dir: "Circular reference sequence directory."
    sample_id: "Sample ID to use in SAM tag."
    fastq_1: "FASTQ Files left reads."
    fastq_2: "FASTQ Files right reads."
    read_group_library: "library parameter for readgroup."
    read_group_platform: "platform parameter for readgroup."
    platform_unit: "PU parameter for readgroup."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
    debug: "Should only map 50000 reads to test."
  }

  meta {
    author: "Pushkala Jayaraman"
    email: "jayaramanp@email.chop.edu"
    gsnap_version: "2019-05-12"
    version: "0.1.0"
  }
}

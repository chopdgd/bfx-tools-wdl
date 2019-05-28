version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://research-pub.gene.com/gmap/
# Task Summary: Align FASTQ files to a circular-aware reference genome using GMAP-GSNAP
# Tool Name: gsnap
# Documentation: http://research-pub.gene.com/gmap/
# -------------------------------------------------------------------------------------------------


task GSnap {
  input {
    File ? gsnap
    File reference_name
    String reference_dir
    String sample_id
    File fastq_1
    File fastq_2

    String userString = "--gunzip --format=sam --nofails --pairmax-dna=500 --query-unk-mismatch=1 -n 1 -O"

    Array[String] modules = []
    Int memory = 1
    Int cpu = 4
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="gsnap" gsnap} \
      -D ~{reference_dir} \
      -d ~{reference_name} \
      -t ~{cpu} \
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
    reference_name: "Name of the reference to use"
    reference_dir: "Circular reference sequence directory."
    sample_id: "Sample ID to use in SAM tag."
    fastq_1: "FASTQ Files left reads."
    fastq_2: "FASTQ Files right reads."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Pushkala Jayaraman"
    email: "jayaramanp@email.chop.edu"
    gsnap_version: "2019-05-12"
    version: "0.1.0"
  }
}

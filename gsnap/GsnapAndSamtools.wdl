version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://research-pub.gene.com/gmap/
# Task Summary: Align FASTQ files to a circular-aware reference genome using GMAP-GSNAP
# Tool Name: gsnap
# Documentation: http://research-pub.gene.com/gmap/
# -------------------------------------------------------------------------------------------------

task GsnapAndSamtools {
  input {
    String ? gsnap
    File ? samtools
    File reference
    File reference_idx
    String circular_reference_dir
    String circular_reference_name
    String sample_id
    File fastq_1
    File fastq_2

    String read_group_id = "~{sample_id}"
    String read_group_name = "~{sample_id}"
    String read_group_library = "Illumina"
    String read_group_platform = "HiSeq"

    String userString = "--format=sam --nofails --pairmax-dna=500 --query-unk-mismatch=1 -n 1 -O -t 4 "
    String ? Samtools_view_parameters
    String ? Samtools_sort_parameters

    Array[String] modules = []
    Int memory = 1
    Int cpu = 16
    Boolean debug = false

    String output_filename_prefix = ""
  }

  String output_filename = sample_id + output_filename_prefix + ".sorted.bam"
  String output_idx_filename = sample_id + output_filename_prefix + ".sorted.bam.bai"

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="gsnap" gsnap} \
      --read-group-id=~{read_group_id} \
      --read-group-name=~{read_group_name} \
      --read-group-library=~{read_group_library} \
      --read-group-platform=~{read_group_platform} \
      -D ~{circular_reference_dir} \
      --gunzip \
      -d ~{default="chrMc" circular_reference_name} \
      ~{userString} ~{fastq_1} ~{fastq_2} | \
      ~{default="samtools" samtools} view \
      -b \
      ~{Samtools_view_parameters} \
      --reference ~{reference} \
      ~{"-@ " + cpu} \
      - | \
      ~{default="samtools" samtools} sort \
      ~{Samtools_sort_parameters} \
      -O BAM \
      ~{"-@ " + cpu} \
      - \
      -o ~{output_filename};

    ~{default="samtools" samtools} index ~{"-@ " + cpu} ~{output_filename} ~{output_idx_filename};
  }

  output {
    File bam_file = "~{output_filename}"
    File bam_idx_file = "~{output_idx_filename}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    gsnap: "gsnap directory that hosts the executable."
    circular_reference_name: "Name of the reference to use"
    circular_reference_dir: "Circular reference sequence directory."
    sample_id: "Sample ID to use in SAM tag."
    fastq_1: "FASTQ Files left reads."
    fastq_2: "FASTQ Files right reads."
    read_group_library: "library parameter for readgroup."
    read_group_platform: "platform parameter for readgroup."
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

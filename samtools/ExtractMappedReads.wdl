version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://www.htslib.org/
# Tool Name: Samtools
# Documentation: http://www.htslib.org/doc/samtools.html
# -------------------------------------------------------------------------------------------------

task ExtractMappedReads {
  input {
    File ? samtools

    File ? reference
    File ? reference_idx

    File input_file
    File ? input_idx_file

    String ? userString

    Array[String] modules = []
    Float memory = 4
    Int cpu = 1
  }

  String output_filename = basename(input_file) + ".mapped.bam"

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="samtools" samtools} view \
      ~{userString} \
      ~{"--reference " + reference} \
      ~{"-@ " + cpu} \
      ~{input_file} | \
    ~{default="samtools" samtools} sort \
      -O BAM \
      ~{"--reference " + reference} \
      ~{"-@ " + cpu} \
      - -o ~{output_filename};

    ~{default="samtools" samtools} index \
      ~{"-@ " + cpu} \
      ~{output_filename} \
      ~{output_filename}.bai;
  }

  output {
    File bam_file = "~{output_filename}"
    File bam_idx_file = "~{output_filename}" + ".bai"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    samtools: "Samtools executable."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    input_file: "bam file."
    input_idx_file: "bam index file."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Pushkala Jayaraman"
    email: "jayaramanp@email.chop.edu"
    samtools_version: "1.9"
    version: "0.1.0"
  }
}

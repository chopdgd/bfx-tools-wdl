version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://www.htslib.org/
# Tool Name: Samtools
# Documentation: http://www.htslib.org/doc/samtools.html
# -------------------------------------------------------------------------------------------------

task ExtractMappedReads {
  input {
    File samtools

    File reference
    File reference_idx

    File bam_file
    File ? bam_idx_file

    String ? userString

    Int ? memory
    Int ? cpu
  }

  String output_filename = basename(bam_file) + ".mapped.bam"

  command {
    set -Eeuxo pipefail;

    ${samtools} view \
      ${userString} \
      --reference ${reference} ${"-@ " + cpu} \
      ${bam_file} | \
      ${samtools} sort \
      -O BAM \
      --reference ${reference} \
      ${"-@ " + cpu} \
      - -o ${output_filename};

      ${samtools} index ${"-@ " + cpu} ${output_filename} ${output_filename}.bai;
  }

  output {
    File output_file = "${output_filename}"
    File output_idx_file = "${output_filename}" + ".bai"
  }

  runtime {
    memory: select_first([memory, 4]) + " GB"
    cpu: select_first([cpu, 1])
  }

  parameter_meta {
    samtools: "Samtools executable."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    bam_file: "bam file."
    bam_idx_file: "bam index file."
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

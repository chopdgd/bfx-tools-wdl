version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: FreeBayes
# Task Summary: FreeBayes is a Bayesian genetic variant detector
# Tool Name: FreeBayes
# Documentation: https://github.com/ekg/freebayes
# -------------------------------------------------------------------------------------------------


task FreeBayes {
  input {
    File freebayes

    File reference
    File reference_idx

    File ? intervals

    String sample_id
    File bam_file
    File bam_idx_file

    String ? userString

    Int ? memory
    Int ? cpu
  }

  String output_filename = sample_id + '.freebayes.vcf'

  command {
    ${freebayes} -f ${reference} ${"-t " + intervals} ${bam_file} ${default="-4 -q 15 -F 0.03" userString} -v ${output_filename};
  }

  output {
    File vcf_file = "${output_filename}"
  }

  runtime {
    memory: select_first([memory, 1]) + " GB"
    cpu: select_first([cpu, 1])
  }

  parameter_meta {
    freebayes: "freebayes executable."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    intervals: "One or more genomic intervals over which to operate."
    bam_file: "Sorted BAM file."
    bam_idx_file: "Sorted BAM index file."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    freebayes_version: "1.0.1"
    version: "0.1.0"
  }
}

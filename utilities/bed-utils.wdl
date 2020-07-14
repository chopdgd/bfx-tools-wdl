version 1.0
# -------------------------------------------------------------------------------------------------
# Utilities used to prepare regions of interest BED and interval_list files.
# -------------------------------------------------------------------------------------------------

task CombineTrim {
  input {
    File bed_file
    Array[File] bed_files

    # Run time variables
    Float memory = 12
    Int cpu = 1
  }

  # Output filenames
  String combined_variant_file = basename(bed_file) + '.combined.bed'
  String trimmed_variant_file = basename(combined_variant_file) + '.trimmed.bed'

  command <<<
    set -Eeuxo pipefail;

    cat ~{bed_file} ~{sep=" " bed_files} > ~{combined_variant_file}; #combine

    cut -f1,2,3,4,5,6,7 ~{combined_variant_file} > ~{trimmed_variant_file}; #trim
  >>>

  output {
    File variant_bed_file = "~{trimmed_variant_file}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    bed_file: "WES main bed file"
    bed_files: "managed variant bed files"
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    version: "0.1.0"
  }
}

version 1.0
# -------------------------------------------------------------------------------------------------
# Utilities used to prepare regions of interest BED and interval_list files.
# -------------------------------------------------------------------------------------------------

task PadCombineTrim {
  input {
    File bed_file
    Array[File] bed_files
    Int variant_calling_padding = 15
    Int coverage_padding = 6

    # Run time variables
    Int memory = 1
    Int cpu = 1
  }

  # Output filenames
  String padded_variant_file = basename(bed_file) + '.variant.padded.bed'
  String padded_coverage_file = basename(bed_file) + '.coverage.padded.bed'
  String combined_variant_file = basename(padded_variant_file) + '.combined.bed'
  String trimmed_variant_file = basename(combined_variant_file) + '.trimmed.bed'

  command <<<
    awk '{$2-=~{variant_calling_padding};$3+=~{variant_calling_padding}}1' OFS='\t' ~{bed_file} > ~{padded_variant_file}; #add padding variant

    cat ~{padded_variant_file} ${sep=" " bed_files} > ~{combined_variant_file}; #combine

    cut -f1,2,3,4,5,6,7 ~{combined_variant_file} > ~{trimmed_variant_file}; #trim

    awk '{$2-=~{coverage_padding};$3+=~{coverage_padding}}1' OFS='\t' ~{bed_file} > ~{padded_coverage_file};
  >>>

  output {
    File variant_bed_file = "~{trimmed_variant_file}"
    File coverage_bed_file = "~{padded_coverage_file}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    bed_file: "WES main bed file"
    bed_files: "managed variant bed files"
    variant_calling_padding: "padding for variant bed file usually 15"
    coverage_padding: "padding for coverage bed file ususally 6"
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    version: "0.1.0"
  }
}

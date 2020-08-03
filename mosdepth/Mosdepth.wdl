version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/brentp/mosdepth
# Task Summary: fast BAM/CRAM depth calculation for WGS, exome, or targeted sequencing.
# Tool Name: mosdepth
# Documentation: https://github.com/brentp/mosdepth
# -------------------------------------------------------------------------------------------------

task Mosdepth {
  input {
    #Tools
    File ? mosdepth

    #Inputs
    File bam_file
    File bam_idx_file
    File depth_bed_file
    String sample_id
    String ? userString

    # Run time variables
    Float memory = 6
    Int cpu = 1
    Array[String] modules = []
  }

  String region_bed = sample_id + ".regions.bed.gz"
  String region_idx_bed = sample_id + ".regions.bed.gz.csi"
  String mosdepth_region_dist = sample_id + ".mosdepth.region.dist.txt"
  String mosdepth_global_dist = sample_id + ".mosdepth.global.dist.txt"
  String mosdepth_summary = sample_id + ".mosdepth.summary.txt"

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="mosdepth" mosdepth} \
      --by ~{depth_bed_file} \
      ~{userString} \
      ~{sample_id} \
      ~{bam_file};
  }

  output {
    File region_bed_file = "~{region_bed}"
    File region_idx_bed_file = "~{region_idx_bed}"
    File mosdepth_region_dist_file = "~{mosdepth_region_dist}"
    File mosdepth_global_dist_file = "~{mosdepth_global_dist}"
    File mosdepth_summary_file = "~{mosdepth_summary}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    mosdepth: "mosdepth executable binary file"
    depth_bed_file: "Exomedepth bed file - Current bed file 35mer"
    bam_file: "Markdups bam file"
    sample_id: "sample id is required for the prefix of output files"
  }

  meta {
    author: "Pushkala Jayaraman"
    email: "jayaramanp@email.chop.edu"
    version: "1.0.0"
  }
}

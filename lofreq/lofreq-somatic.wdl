version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/CSB5/lofreq
# Task Summary: Fast and sensitive variant calling from next-gen sequencing data
# Tool Name: LoFreq somatic
# Documentation: http://csb5.github.io/lofreq/commands/
# -------------------------------------------------------------------------------------------------


task LoFreqSomatic {
  input {
    String lofreq

    File tumor_bam
    File tumor_bam_idx
    File normal_bam
    File normal_bam_idx

    File bed_file
    String sample_id

    File reference
    File reference_idx
    File ? dbsnp
    File ? dbsnp_idx

    String userString = "--verbose --min-cov 1"

    Array[String] modules = []
    Float memory = 12
    Int cpu = 12
  }

  String output_filename_prefix = sample_id + '.'

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{lofreq} somatic \
      --threads ~{cpu} \
      ~{userString} \
      --normal ~{normal_bam} \
      --tumor ~{tumor_bam} \
      --outprefix ~{output_filename_prefix} \
      --ref ~{reference} \
      ~{"--dbsnp " + dbsnp} \
      --bed ~{bed_file};
  }

  output {
    File final_vcf = "${output_filename_prefix}" + "somatic_final.snvs.vcf.gz"
    File final_minus_dbsnp_vcf = "${output_filename_prefix}" + "somatic_final_minus-dbsnp.snvs.vcf.gz"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    lofreq: "Path to lofreq binary (String due to nearby dependencies"
    normal_bam: "The BAM file with reads from normal sample"
    tumor_bam: "The BAM file with reads from the tumor sample"
    reference: "FASTA reference"
		reference_idx: "FASTA index reference (.fai)"
		bed_file: "ROI in BED format"
    userString: "An optional parameter which allows the user to specify additions to the command line at run time"
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    lofreq_version: "2.1.3.1"
    version: "0.1.0"
  }
}

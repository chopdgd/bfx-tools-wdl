version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: MuTect v2, GATK v3.8.1
# Task Summary: Call somatic SNPs and indels via local re-assembly of haplotypes
# Tool Name: MuTect2
# -------------------------------------------------------------------------------------------------


task MuTect2 {
  input {
    File ? java
    File gatk

    File tumor_bam
    File tumor_bam_idx
    String sample_id

    File ? normal_bam
    File ? normal_bam_idx
    String ? normal_sample_id

    Array[File] intervals = []

    File reference
    File reference_idx
    File reference_dict

    File ? dbsnp_vcf
    File ? cosmic_vcf
    File ? panel_of_normals
    String ? userString

    Array[String] modules = []
    Float memory = 64
    Int cpu = 16
  }

  String output_vcf_name = sample_id + '.MuTect2.vcf'
  Array[String] intervalOptions = prefix("--intervals ", intervals)

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="java" java} -jar ~{gatk} \
      -T MuTect2 \
      -nct ~{cpu} \
      -R ~{reference} \
      -I:tumor ~{tumor_bam} \
      ~{sep=" " intervalOptions} \
      ~{"-I:normal " + normal_bam} \
      ~{"--cosmic " + cosmic_vcf} \
      ~{"--dbsnp " + dbsnp_vcf} \
      ~{userString} \
      ~{"--panel-of-normals " + panel_of_normals} \
      -o ~{output_vcf_name};
  }

  output {
    File vcf_file = "~{output_vcf_name}"
    File vcf_idx_file = "~{output_vcf_name}" + ".idx"
  }

  runtime {
    memory: memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    gatk: "GATK <v4.0.0 jar file"
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    reference_dict: "Reference sequence dict (.dict)."
    tumor_bam: "BAM file for tumor sample; required."
    sample_id: "ID for the tumor_bam."
    normal_bam: "BAM file for normal sample; not required"
    normal_sample_id: "ID for the normal sample; required if normal_bam is provided"
    panel_of_normals: "VCF built with MuTect2 CreateSomaticPanelOfNormals"
    intervals: "One or more genomic intervals over which to operate."
    sample_id: "tumor sample id; prefix for output files"
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    gatk_version: "3.8.1"
    version: "0.1.0"
  }
}

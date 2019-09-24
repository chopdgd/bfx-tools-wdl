version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: MuTect v2, GATK v4.1+
# Task Summary: Call somatic SNPs and indels via local re-assembly of haplotypes
# Tool Name: MuTect2
# Archived MuTect: https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.2.0/org_broadinstitute_hellbender_tools_walkers_mutect_Mutect2.php
# Note: While this tool does support calling multiple tumor/normal pairs at once, for the sake of modularity
#				this task only calls one tumor/normal pair at at time. This task can be called in a loop to run
#				multiple pairs. It also supports tumor only invocation, including "--mitochondria"
# -------------------------------------------------------------------------------------------------


task MuTect2 {
  input {
    File ? gatk

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

    File ? dbsnp
    File ? dbsnp_idx
    File ? cosmic
    File ? panel_of_normals
    File ? germline_resource
    String ? userString

    Array[String] modules = []
    Float memory = 12
    Int cpu = 1
  }

  String output_vcf_name = sample_id + '.MuTect2.vcf'
  Array[String] intervalOptions = prefix("--intervals ", intervals)

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="gatk" gatk} MuTect2 \
      -R ~{reference} \
      -I ~{tumor_bam} \
      ~{sep=" " intervalOptions} \
      ~{"-I " + normal_bam} \
      ~{"-normal " + normal_sample_id} \
      ~{userString} \
      ~{"--panel-of-normals " + panel_of_normals} \
      ~{"--germline-resource " + germline_resource} \
      ~{"--dbsnp " + dbsnp} \
      ~{"--cosmic " + cosmic} \
      -O ~{output_vcf_name};
  }

  output {
    File vcf_file = "~{output_vcf_name}"
  }

  runtime {
    memory: memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    gatk: "GATK v4.1+ binary"
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    reference_dict: "Reference sequence dict (.dict)."
    tumor_bam: "BAM file for tumor sample; required."
    sample_id: "ID for the tumor_bam."
    normal_bam: "BAM file for normal sample; not required"
    normal_sample_id: "ID for the normal sample; required if normal_bam is provided"
    dbsnp: "dbSNP VCF file."
    dbsnp_idx: "dbSNP VCF index file (.tbi)."
    cosmic: "COSMIC VCF downloaded from Sanger Institute."
    panel_of_normals: "VCF built with MuTect2 CreateSomaticPanelOfNormals"
    germline_resource: "VCF of other germline events, e.g. gnomAD"
    intervals: "One or more genomic intervals over which to operate."
    sample_id: "tumor sample id; prefix for output files"
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    gatk_version: "4.1.2"
    version: "0.1.0"
  }
}

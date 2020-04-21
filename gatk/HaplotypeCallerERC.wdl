version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://software.broadinstitute.org/gatk/
# Task Summary: Call germline SNPs and indels via local re-assembly of haplotypes
# Tool Name: GATK HaplotypeCaller ERC
# Documentation: https://software.broadinstitute.org/gatk/documentation/tooldocs/3.8-0/org_broadinstitute_gatk_tools_walkers_haplotypecaller_HaplotypeCaller.php
# Example: https://software.broadinstitute.org/wdl/documentation/article?id=7615
# Notes:
#  * When running in `-ERC GVCF` or `-ERC BP_RESOLUTION` modes, the emitting and calling confidence thresholds are automatically set to 0
#  * Naming your output file using the .g.vcf extension will automatically set the appropriate values  for --variant_index_type and --variant_index_parameter
# -------------------------------------------------------------------------------------------------


task HaplotypeCallerERC {
  input {
    File ? java
    File ? gatk
    File reference
    File reference_idx
    File reference_dict

    Array[File] intervals = []
    File ? dbsnp
    File ? dbsnp_idx

    String sample_id
    File bam_file
    File bam_idx_file

    String ? userString

    Array[String] modules = []
    Float memory = 12
    Int cpu = 1

    String gvcf_filename = sample_id + ".rawLikelihoods.g.vcf.gz"
    String gvcf_idx_filename = sample_id + ".rawLikelihoods.g.vcf.gz.tbi"
  }

  Int jvm_memory = round(memory)
  Array[String] intervalOptions = prefix("--intervals ", intervals)

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{jvm_memory}g \
      -jar ~{default="gatk" gatk} \
      -T HaplotypeCaller -ERC GVCF \
      ~{userString} \
      -nct ~{cpu} \
      ~{"--dbsnp " + dbsnp} \
      -R ~{reference} \
      -I ~{bam_file} \
      ~{sep=" " intervalOptions} \
      -o ~{gvcf_filename};
  }

  output {
    File gvcf_file = "~{gvcf_filename}"
    File gvcf_idx_file = "~{gvcf_idx_filename}"
  }

  runtime {
    memory: memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    java: "Path to Java."
    gatk: "GATK jar file."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    reference_dict: "Reference sequence dict (.dict)."
    dbsnp: "dbSNP VCF file."
    dbsnp_idx: "dbSNP VCF index file (.tbi)."
    intervals: "One or more genomic intervals over which to operate."
    sample_id: "prefix for output files"
    bam_file: "Sorted and duplicate marked BAM file"
    bam_idx_file: "BAM file index (.bai)"
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    gatk_version: "3.8"
    version: "0.1.0"
  }
}

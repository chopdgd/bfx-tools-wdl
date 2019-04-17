version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://software.broadinstitute.org/gatk/
# Task Summary: Perform joint genotyping on gVCF files produced by HaplotypeCaller
# Tool Name: GATK GenotypeGVCFs
# Documentation: https://software.broadinstitute.org/gatk/documentation/tooldocs/3.8-0/org_broadinstitute_gatk_tools_walkers_variantutils_GenotypeGVCFs.php
# Example: https://software.broadinstitute.org/wdl/documentation/article?id=7615
# -------------------------------------------------------------------------------------------------


task GenotypeGVCFs {
  input {
    File ? java
    File ? gatk
    File reference
    File reference_idx
    File reference_dict

    Array[File] intervals = []
    File ? dbsnp
    File ? dbsnp_idx

    String cohort_id
    Array[File] gvcf_files
    Array[File] gvcf_idx_files

    Float stand_call_conf = 10.0
    String ? userString

    Array[String] modules = []
    Int memory = 4
    Int cpu = 1
  }

  Array[String] intervalOptions = prefix("--intervals ", intervals)

  String vcf_filename = cohort_id + ".rawVariants.vcf.gz"
  String vcf_filename_idx = cohort_id + ".rawVariants.vcf.gz.tbi"

  command {
    set -Eeuxo pipefail;

    for MODULE in ${sep=' ' modules}; do
      module load $MODULE
    done;

    ${default="java" java} \
      -Xmx${memory}g \
      -jar ${default="gatk" gatk} \
      -T GenotypeGVCFs \
      ${userString} \
      -stand_call_conf ${stand_call_conf} \
      ${"--dbsnp " + dbsnp} \
      -nt ${cpu} \
      -R ${reference} \
      ${sep=" " prefix("--variant ", gvcf_files)} \
      ${sep=" " intervalOptions} \
      -o ${vcf_filename};
  }

  output {
    File vcf_file = "${vcf_filename}"
    File vcf_idx_file = "${vcf_filename_idx}"
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
    intervals: "One or more genomic intervals over which to operate."
    cohort_id: "Prefix of the output VCF filename."
    gvcf_files: "One or more gVCF files."
    gvcf_idx_files: "One or more gVCF index files (.tbi)."
    stand_call_conf: "The minimum phred-scaled confidence threshold at which variants should be called."
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

version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://software.broadinstitute.org/gatk/
# Task Summary: Validate a VCF/gVCF file with a strict set of criteria
# Tool Name: GATK ValidateVariants
# Documentation: https://software.broadinstitute.org/gatk/documentation/tooldocs/4.0.0.0/org_broadinstitute_hellbender_tools_walkers_variantutils_ValidateVariants.php
# -------------------------------------------------------------------------------------------------


task ValidateVariants {
  input {
    File ? gatk
    File reference
    File reference_idx
    File reference_dict

    File input_file
    File ? input_idx_file
    File ? dbsnp
    File ? dbsnp_idx

    Array[File] ? intervals
    String ? userString

    Array[String] modules = []
    Float memory = 4
    Int cpu = 1
  }


  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="gatk" gatk} \
      ValidateVariants \
      ~{userString} \
      --reference ~{reference} \
      --sequence-dictionary ~{reference_dict} \
      ~{"--dbsnp " + dbsnp} \
      --variant ~{input_file};

    echo "true"
  }

  output {
    Boolean status = read_boolean(stdout())
  }

  runtime {
    memory: memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    gatk: "GATK4 file"
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    reference_dict: "Reference sequence dict (.dict)."
    input_file: "A VCF or gVCF file."
    input_idx_file: "A VCF or gVCF index files (.tbi)."
    dbsnp: "dbSNP VCF file."
    dbsnp_idx: "dbSNP VCF index file (.tbi)."
    intervals: "Array of interval lists to restrict region to (not useful with gVCFs."
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

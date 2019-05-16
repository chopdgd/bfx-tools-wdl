version 1.0
# -------------------------------------------------------------------------------------------------
# Task Summary: somatic append pindel vcf
# -------------------------------------------------------------------------------------------------

task AppendPindel {
  input {
    # Input VCF Files
    File vcf_file
    File pindel_vcf

    # Resource Allocation
    Int memory = 1
    Int cpu = 1
  }

  String output_filename = basename(vcf_file) + "_merged.vcf.td.vcf"

  command {
    set -Eeuxo pipefail;

    cat ~{vcf_file} ~{pindel_vcf} > tmp.vcf;
    grep '^#' tmp.vcf > ~{output_filename};
    grep -v '^#' tmp.vcf | LC_ALL=C sort -k1,1 -k2,2n >> ~{output_filename};
  }

  output {
    File output_file = "~{output_filename}"
  }

  parameter_meta {
    vcf_file: "Main VCF"
    pindel_vcf: "VCF with variant calls from Pindel"
  }

  meta {
    author: "cao k"
    email: "caok@email.chop.edu"
    version: "0.1.0"
  }
}

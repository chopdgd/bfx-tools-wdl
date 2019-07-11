version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/dkoboldt/varscan
# Task Summary: VarScan is a tool that detects copy number variants in NGS data
# Tool Name: VarScan Somatic
# Documentation: http://varscan.sourceforge.net/using-varscan.html#v2.3_somatic
# -------------------------------------------------------------------------------------------------


task Somatic {
  input {
    File ? java
    File ? varscan

    String sample_id
    File normal_mpileup
    File tumor_mpileup

    String userString = "--min-var-freq 0.03 --strand-filter 1"

    Array[String] modules = []
    Float memory = 4
    Int cpu = 1
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{memory}g \
      -jar ~{default="varscan" varscan} somatic \
      ~{normal_mpileup} \
      ~{tumor_mpileup} \
      ~{sample_id} \
      ~{userString} \
      --output-vcf 1;
  }

  output {
    File snp_vcf_file = "~{sample_id}" + '.snp.vcf'
    File indel_vcf_file = "~{sample_id}" + '.indel.vcf'
  }

  runtime {
    memory: memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    java: "Path to Java."
    varscan: "varscan JAR file."
    sample_id: "sample id; used for output file naming"
    normal_mpileup: "Samtools mpileup file for control bam; must come before tumor bam."
    tumor_mpileup: "Samtools mpileup file for tumor bam; must come after control bam."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    varscan_version: "2.4.2"
    version: "0.3.0"
  }
}

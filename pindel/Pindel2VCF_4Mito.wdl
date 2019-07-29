version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://gmt.genome.wustl.edu/packages/pindel/
# Task Summary: Pindel can detect breakpoints of large deletions, medium sized insertions, inversions, tandem duplications and other structural variants at single-based resolution from next-gen sequence data
# Tool Name: Pindel
# Documentation: http://gmt.genome.wustl.edu/packages/pindel/user-manual.html
# -------------------------------------------------------------------------------------------------

task Pindel2VCF4Mito {
  
  input {
  
    File ? pindel2vcf
    File reference
    File reference_idx
    String reference_version =  "NC_012920"
    String reference_date = "10312014"

    File sample_id_cnv

    String ? userString

    Array[String] modules = []
    Float memory = 8
    Int cpu = 1
  }
  
  String sample = basename(sample_id_cnv "_D")
  
  String output_file = sample + ".vcf"

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="pindel2vcf" pindel2vcf} \
    ~{userString} \
    -r ~{reference} \
    -R ~{reference_version} \
    -d ~{reference_date} \
    -P ~{sample} \
    -v ~{output_file};
  }

  output {
    File vcf_file = "~{output_file}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    pindel2vcf: "pindel2vcf executable."
    reference: "reference file."
    reference_idx: "reference idx."
    reference_version: "The name and version of the reference genome."
    sample: "sample identifier."
    reference_date: "The date of the version of the reference genome used."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Pushkala Jayaraman"
    email: "jayaramanp@email.chop.edu"
    pindel_version: "0.2.5"
    version: "0.1.0"
  }
}

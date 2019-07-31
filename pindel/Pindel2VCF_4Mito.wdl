version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: http://gmt.genome.wustl.edu/packages/pindel/
# Task Summary: Pindel can detect breakpoints of large deletions, medium sized insertions, inversions, tandem duplications and other structural variants at single-based resolution from next-gen sequence data
# Tool Name: Pindel
# Documentation: http://gmt.genome.wustl.edu/packages/pindel/user-manual.html
# -------------------------------------------------------------------------------------------------

task PindelCNV2VCF4Mito {

  input {

    File ? pindel

    File bam_file
    File bam_idx_file

    Int sliding_window = 300
    String pindel_userString = "-t"

    Array[String] modules = []
    
    File ? pindel2vcf
    File reference
    File reference_idx
    String reference_version="NC_012920"
    String reference_date="10312014"

    File sample_id

    String ? pindel2vcf_userString

    Array[String] modules = []
    Float memory = 8
    Int cpu = 1
  }

  String output_file = sample_id + ".vcf"

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    echo -e ~{bam_file}"\t"~{sliding_window}"\t"~{sample_id} > config;

    ~{default="pindel" pindel} \
      ~{userString} \
      ~{"-j " + intervals} \
      -f ~{reference} \
      -L ~{sample_id + ".log"}
      -i config \
      -o ~{sample_id};

    ~{default="pindel2vcf" pindel2vcf} \
    ~{userString} -r ~{reference} -R ~{reference_version} \
    -d ~{reference_date} -P ~{sample_id} \
    -v ~{output_file}
  }

  output {
    File deletion_file = "~{sample_id}" + "_D"
    File short_insertion_file = "~{sample_id}" + "_SI"
    File inversion_file = "~{sample_id}" + "_INV"
    File tandem_duplication_file = "~{sample_id}" + "_TD"
    File large_insertion_file = "~{sample_id}" + "_LI"
    File unassigned_breakpoints_file = "~{sample_id}" + "_BP"
    File CloseEndMapped_file = "~{sample_id}" + "_CloseEndMapped"
    File INT_file = "~{sample_id}" + "_INT_final"
    File RP_file = "~{sample_id}" + "_RP"
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

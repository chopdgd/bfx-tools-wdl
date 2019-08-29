version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/suhrig/arriba
# Task Summary: Detects gene fusions from RNA-Seq downstream of STAR-Align
# Tool Name: Arriba
# Documentation: https://arriba.readthedocs.io/en/latest/quickstart/
# -------------------------------------------------------------------------------------------------

task Arriba {
  input {
    File arriba
    File bam_file
    File reference
    File gtf
    File arriba_blacklist
    String sample_id

    String userString = "-T -P"

    Array[String] modules = []
    Float memory = 8
    Int cpu = 2
  }

  String fusion_output = "~{sample_id}" + '.arriba.fusions.tsv'
  String discarded_fusion_output = "~{sample_id}" + '.arriba.discarded_fusions.tsv'

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{arriba} \
      -x ~{bam_file} \
      -a ~{reference} \
      -g ~{gtf} \
      ~{userString} \
      -b ~{arriba_blacklist} \
      -o ~{fusion_output} \
      -O ~{discarded_fusion_output}
  }

  output {
    File arriba_fusion_tsv = "~{fusion_output}"
    File arriba_discared_fusion_tsv = "~{discarded_fusion_output}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    arriba: "Path to Arriba."
    bam_file: "The aligned genome bam from STAR (not the transcriptome or bam with read groups)."
    reference: "Genome fasta used in STAR."
    gtf: "GTF file used to generate the STAR index."
    arriba_blacklist: "Gene blacklist provided by Arriba releases."
    sample_id: "Prefix for output files."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    arriba_version: "1.1.0"
    version: "0.2.0"
  }
}

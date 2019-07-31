version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/Illumina/manta
# Task Summary: Manta calls structural variants (SVs) and indels from mapped paired-end sequencing reads. It is optimized for analysis of germline variation in small sets of individuals and somatic variation in tumor/normal sample pairs.
# Tool Name: Manta
# Documentation: https://github.com/Illumina/manta/tree/master/docs
# -------------------------------------------------------------------------------------------------


task ConfigRunManta{
  
  input {
    String ? python
    File ? manta

    File reference
    File ? reference_idx

    String sample_id
    File bam_file
    File bam_idx_file

    String ? userString

    Array[String] modules = []
    Float memory = 4
    Int cpu = 1
  }

  String run_directory = "./"+sample_id

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="python" python} \
      ~{manta}
      ~{"--tumorBam " + bam_file} \
      ~{"--referenceFasta " + reference} \
      ~{"--runDir " + run_directory};

      ~{default="python" python} ~{run_directory}/runWorkflow.py ~{default="-m local -j 8" userString};

  }

  output {
    File vcfFile = run_directory + "/results/variants/tumorSV.vcf.gz"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    manta: "manta Config executable."
    reference: "reference file."
    reference_idx: "reference idx."
    sample_id: "sample id."
    bam_file: "BAM file."
    bam_idx_file: "BAM index file."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Pushkala Jayaraman"
    email: "jayaramanp@email.chop.edu"
    pindel_version: "1.4.0"
    version: "0.1.0"
  }
}

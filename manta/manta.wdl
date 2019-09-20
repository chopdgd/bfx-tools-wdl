version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/Illumina/manta
# Task Summary: Manta calls structural variants (SVs) and indels from mapped paired-end sequencing reads. It is optimized for analysis of germline variation in small sets of individuals and somatic variation in tumor/normal sample pairs.
# Tool Name: manta
# Documentation: https://github.com/Illumina/strelka/blob/v2.9.x/docs/userGuide/README.md
# Example: https://github.com/Illumina/manta/blob/master/docs/userGuide/README.md#somatic-configuration-examples
# -------------------------------------------------------------------------------------------------


task Manta {
  input {
    File ? python
    String manta

    File tumor_input
    File tumor_input_idx
    File ? normal_input
    File ? normal_input_idx

    File bed_file_bgzip
    File bed_file_idx
    File reference
    File reference_idx

    String ? userString

    Array[String] modules = []
    Float memory = 16
    Int cpu = 4
  }

  Int pymem = round(memory)

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="python" python} ~{manta} \
      ~{"--normalBam " + normal_input} \
      --tumorBam ~{tumor_input} \
      --referenceFasta ~{reference} \
      --callRegions ~{bed_file_bgzip} \
      ~{userString} \
      --runDir manta_run;

    ~{default="python" python} manta_run/runWorkflow.py \
      --mode local \
      --jobs ~{cpu} \
      --memGb ~{pymem};
  }

  output {
    File vcf_file = "manta_run/results/variants/somaticSV.vcf.gz"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    python: "Path to Python binary"
    manta: "Path to manta Python script"
    bed_file_bgzip: "ROI in BED file format that has been BgZip'd"
    bed_file_idx: "BgZip'd BED file indexed with Tabix"
    reference: "FASTA reference file"
    reference_idx: "FASTA reference fil index (.fai)"
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    manta_verison: "1.6.0"
    version: "0.1.0"
  }
}

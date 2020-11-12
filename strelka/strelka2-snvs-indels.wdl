version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/Illumina/strelka
# Task Summary: fast and accurate small variant caller optimized for analysis of germline variation in small cohorts and somatic variation in tumor/normal sample pairs
# Tool Name: Strelka2
# Documentation: https://github.com/Illumina/strelka/blob/v2.9.x/docs/userGuide/README.md
# Example: https://github.com/Illumina/strelka/blob/v2.9.x/docs/userGuide/README.md#somatic-configuration-example
# -------------------------------------------------------------------------------------------------


task Strelka2Merged {
  input {
    File ? python
    File ? gatk
    String strelka2

    File tumor_input
    File tumor_input_idx
    File ? normal_input
    File ? normal_input_idx

    File ? bed_file_bgzip
    File ? bed_file_idx
    File reference
    File reference_idx
    File reference_dict

    String sample_id
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

    ~{default="python" python} ~{strelka2} \
      ~{"--normalBam " + normal_input} \
      --tumorBam ~{tumor_input} \
      --referenceFasta ~{reference} \
      ~{"--callRegions " + bed_file_bgzip} \
      ~{userString} \
      --runDir strelka2_run;

    ~{default="python" python} strelka2_run/runWorkflow.py \
      --mode local \
      --jobs ~{cpu} \
      --memGb ~{pymem};

    ~{default="gatk" gatk} MergeVcfs \
      --SEQUENCE_DICTIONARTY ~{reference_dict} \
      -I strelka2_run/results/variants/somatic.snvs.vcf.gz -I strelka2_run/results/variants/somatic.indels.vcf.gz \
      --OUTPUT strelka2_run/results/variants/~{sample_id}.strelka2.somatic.merged.vcf.gz
  }

  output {
    File vcf_file = "strelka2_run/results/variants/" + "~{sample_id}" + ".strelka2.somatic.merged.vcf.gz"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    python: "Path to Python binary"
    strelka2: "Path to strelka2 Python script"
    bed_file_bgzip: "ROI in BED file format that has been BgZip'd"
    bed_file_idx: "BgZip'd BED file indexed with Tabix"
    reference: "FASTA reference file"
    reference_idx: "FASTA reference fil index (.fai)"
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    strelka2_verison: "2.9.10"
    version: "0.2.0"
  }
}

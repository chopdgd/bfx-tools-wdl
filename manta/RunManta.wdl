version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/Illumina/manta
# Task Summary: Manta calls structural variants (SVs) and indels from mapped paired-end sequencing reads. It is optimized for analysis of germline variation in small sets of individuals and somatic variation in tumor/normal sample pairs.
# Tool Name: Manta
# Documentation: https://github.com/Illumina/manta/tree/master/docs
# -------------------------------------------------------------------------------------------------


task CallMantaCNV {
  input {
    File ? python
    String sample_id

    String userString "-m local -j 16"
    Array[String] modules = []
    Float memory = 4
    Int cpu = 1
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    run_directory = ~{sample_id}+"/"

    ~{default="python" python} \
      ~{run_directory + "runWorkflow.py"}
      ~{userString};
  }

  output {
    File mantaVCF = run_directory + "results/variants/tumorSV.vcf.gz"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    sample_id: "sample id."
    run_directory: the directory in which the runWorkflow.py will be generated. This will be run in the next step.
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

version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/Illumina/manta
# Task Summary: Manta calls structural variants (SVs) and indels from mapped paired-end sequencing reads. It is optimized for analysis of germline variation in small sets of individuals and somatic variation in tumor/normal sample pairs. 
# Tool Name: Manta
# Documentation: https://github.com/Illumina/manta/tree/master/docs
# -------------------------------------------------------------------------------------------------


task ConfigManta{
  input {
    File ? python
    File ? manta

    File reference
    File ? reference_idx

    String sample_id
    File bam_file
    File bam_idx_file

    

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
      ~{manta + "configManta.py"}
      ~{"--tumorBam" + bam_file} \
      ~{"--referenceFasta " + reference} \
      ~{"--runDir" + run_directory};
  }

  output {
    File workflowFile = stdout()
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
    runDir: the directory in which the runWorkflow.py will be generated. This will be run in the next step. 
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

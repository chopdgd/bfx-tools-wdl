version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: In house script to generate variant output for mito
# -------------------------------------------------------------------------------------------------

task HaploGrep {
  input {
    # Tools
    File ? java
    File haplogrep

    # Inputs
    File vcf_file
    String sample_id
    String format = "vcf"
    String ? userString

    # Run time variables
    Int memory = 6
    Int cpu = 1
    Array[String] modules = []
  }
  
  String haplogrep_filename = sample_id + "_haplogrep.out"

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{memory}g \
      -jar ~{default="haplogrep" haplogrep} \
      --format ~{format} \
      --in ~{vcf_file} \
      --out ~{haplogrep_filename} \
      ~{userString}
  }

  output {
    File output_haplogrep = "~{haplogrep_filename}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    haplogrep: "haplogrep jar file"
    sample_id: "proband sample id"
    vcf_file: "input vcf"
  }

  meta {
    author: "Jayaraman"
    email: "jayaramanp@email.chop.edu"
    script: "parse_final_results_add_columns.py"
    version: "0.1.0"
  }
}

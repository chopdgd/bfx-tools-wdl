version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: In house script to generate variant output for mito
# -------------------------------------------------------------------------------------------------

task HaploGrep {
  input {
    # Tools
    File ? java
    File ? dot
    File haplogrep

    # Inputs
    File vcf_file
    String sample_id
    String format = "vcf"
    String ? userString

    # Run time variables
    Float memory = 6
    Int cpu = 1
    Array[String] modules = []

    String haplogrep_filename = sample_id + "_haplogrep.out"
  }

  Int jvm_memory = round(memory)
  String haplogrep_filename = sample_id + "_haplogrep.out"
  String haplogrep_lineage = sample_id + "_haplogrep.out.dot"
  String lineage_pdf_name = sample_id + "_lineage.pdf"

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{jvm_memory}g \
      -jar ~{default="haplogrep" haplogrep} \
      --format ~{format} \
      --in ~{vcf_file} \
      --out ~{haplogrep_filename} \
      ~{userString};

    ~{default="dot" dot} ~{haplogrep_lineage} -Tpdf > ~{lineage_pdf_name};
  }

  output {
    File output_haplogrep = "~{haplogrep_filename}"
    File output_lineage = "~{haplogrep_lineage}"
    File lineage_pdf_file = "~{lineage_pdf_name}"
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

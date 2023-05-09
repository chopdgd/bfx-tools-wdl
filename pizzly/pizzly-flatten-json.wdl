version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/pmelsted/pizzly
# Task Summary: Pizzly Python script to flatten it's own output .json into a single gene table
# Tool Name: flatten_json.py
# Documentation: https://github.com/pmelsted/pizzly/blob/master/README.md
# -------------------------------------------------------------------------------------------------

task PizzlyFlattenJSON {
  input {
    String ? python
    File script
    File pizzly_json
    String sample_id

    String ? userString

    File image
    Float memory = 12
    Int cpu = 1

    String output_filename = "~{sample_id}" + '.genetable.txt'
  }

  command {
    set -Eeuxo pipefail;

    ~{default="python" python} \
      ~{script} \
      ~{pizzly_json} \
      ~{userString} \
      ~{output_filename}
  }

  output {
    File output_genetable = "~{output_filename}"
  }

  runtime {
    singularity: true
    image: image
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    python: "Path to python binary within container"
    script: "Path to Pizzly dev's python script."
    pizzly_json: "Output from the pizzly.wdl task."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    version: "0.1.0"
  }
}

version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/pmelsted/pizzly
# Task Summary: Pizzly Python script to flatten it's own output .json into a single gene table
# Tool Name: flatten_json.py
# Documentation: https://github.com/pmelsted/pizzly/blob/master/README.md
# -------------------------------------------------------------------------------------------------

task PostPizzly {
  input {
    String ? python
    File script
    File pizzly_json
    String sample_id

    Array[String] modules = []
    Float memory = 1
    Int cpu = 1
  }

  String output_filename = "~{sample_id}" + '.genetable.txt'

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="python" python} \
      ~{script} \
      ~{pizzly_json} \
      ~{output_filename}
  }

  output {
    File output_genetable = "~{output_filename}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    python: "Python binary."
    script: "Path to Pizzly dev's python script."
    pizzly_json: "Output from the pizzly.wdl task."
    modules: "Modules to load when task is called; modules must be compatible with the platform the task runs on."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    version: "0.1.0"
  }
}

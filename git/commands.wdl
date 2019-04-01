version 1.0
# -------------------------------------------------------------------------------------------------
# Commonly used git commands
# -------------------------------------------------------------------------------------------------


task Clone {
  input {
    File ? git
    String repo
    String clone_directory
    String branch = "develop"
    String ? userString

    Array[String] modules = []
    Int memory = 1
    Int cpu = 1
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ${sep=' ' modules}; do
      module load $MODULE
    done;

    ${default="git" git} \
      clone ${repo} \
      ${clone_directory} \
      ${userString} \
      -b ${branch};

    echo $PWD/${clone_directory} > directory.txt;
  }

  output {
    File repo_directory = read_string("./directory.txt")
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }
}

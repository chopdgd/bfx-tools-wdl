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

    File image
    Float memory = 12
    Int cpu = 1
  }

  command {
    set -Eeuxo pipefail;

    ~{default="git" git} \
      clone ~{repo} \
      ~{clone_directory} \
      ~{userString} \
      -b ~{branch};

    echo $PWD/~{clone_directory} > directory.txt;
  }

  output {
    File repo_directory = read_string("./directory.txt")
  }

  runtime {
    singularity: true
    image: image
    memory: memory + " GB"
    cpu: cpu
  }
}

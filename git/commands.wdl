version 1.0
# -------------------------------------------------------------------------------------------------
# Commonly used git commands
# -------------------------------------------------------------------------------------------------
task Clone {
  input {
    File ? git
    String repo
    String clone_directory
    String ? branch
    String ? userString
  }

  command {
    set -Eeuxo pipefail;

    ${default="git" git} \
      clone ${repo} \
      ${clone_directory} \
      ${default="" userString} \
      -b ${default="develop" branch};

      echo $PWD/${clone_directory} > directory.txt
  }

  output {
    File repo_directory = read_string("./directory.txt")
  }
}

version 1.0
# -------------------------------------------------------------------------------------------------
# Create python virtualenv w/ specific requirements
# -------------------------------------------------------------------------------------------------

task CreateVirtualenv {
  input {
    String version = 'python2.7'
    String name = 'pyenv'
    File requirements

    Array[String] modules = []
    Int memory = 1
    Int cpu = 1
  }

  String python_filename = name + "/bin/python"
  String pip_filename = name + "/bin/pip"

  command {
    set -Eeuxo pipefail;

    for MODULE in ${sep=' ' modules}; do
        module load $MODULE
    done;

    virtualenv --python=${version} ${name};
    ${pip_filename} install --user -r ${requirements};
  }

  output {
    File python = "${python_filename}"
    File pip = "${pip_filename}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }
}

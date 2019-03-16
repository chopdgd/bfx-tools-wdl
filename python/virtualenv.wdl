version 1.0
# -------------------------------------------------------------------------------------------------
# Create python virtualenv w/ specific requirements
# -------------------------------------------------------------------------------------------------

task CreateVirtualenv {
  input {
    String ? version = 'python2.7'
    String ? name = 'pyenv'
    File requirements
  }

  String python_filename = name + "/bin/python"
  String pip_filename = name + "/bin/pip"

  command {
    set -Eeuxo pipefail;
    virtualenv --python=${version} ${name};
    ${pip_filename} install -r ${requirements};
  }

  output {
    File python = "${python_filename}"
    File pip = "${pip_filename}"
  }
}

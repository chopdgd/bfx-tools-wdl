version 1.0
# -------------------------------------------------------------------------------------------------
# Create python virtualenv w/ specific requirements
# -------------------------------------------------------------------------------------------------

task CreateVirtualenv {
  input {
    String ? version
    String name = 'pyenv'
    File requirements
    Array[String] python_modules = ['python39']

    Array[String] modules = []
    Float memory = 16
    Int cpu = 1

    String python_binary = name + "/bin/python"
  }

  command {
    set -Eexo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    for PYTHON_MODULE in ~{sep=' ' python_modules}; do
        module load $PYTHON_MODULE
    done;

    virtualenv ~{if version then "--python"version else ""} ~{name};

    source ~{name}/bin/activate;
    ~{python_binary} -m pip install setuptools==57.5.0
    ~{python_binary} -m pip install -r ~{requirements};

    echo $PWD/~{python_binary} > python.path;
  }

  output {
    String python = read_string("./python.path")
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }
}

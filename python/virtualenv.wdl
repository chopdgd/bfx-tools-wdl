version 1.0
# -------------------------------------------------------------------------------------------------
# Create python virtualenv w/ specific requirements
# -------------------------------------------------------------------------------------------------

task CreateVirtualenv {
  input {
    String version = 'python2.7'
    String name = 'pyenv'
    File requirements
    Array[String] python_modules = ['python/2.7']

    Array[String] modules = []
    Float memory = 4
    Int cpu = 1
  }

  String python_binary = name + "/bin/python"

  command {
    set -Eexo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    for PYTHON_MODULE in ~{sep=' ' python_modules}; do
        module load $PYTHON_MODULE
    done;

    virtualenv --python=~{version} ~{name};

    for PYTHON_MODULE in ~{sep=' ' python_modules}; do
        module unload $PYTHON_MODULE
    done;

    source ~{name}/bin/activate;

    pip install -r ~{requirements};

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

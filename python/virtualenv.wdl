version 1.0
# -------------------------------------------------------------------------------------------------
# Create python virtualenv w/ specific requirements
# -------------------------------------------------------------------------------------------------

task CreateVirtualenv {
  input {
    String version = 'python2.7'
    String name = 'pyenv'
    File requirements

    Array[String] modules = ['python/2.7']
    Int memory = 1
    Int cpu = 1
  }

  String python_binary = name + "/bin/python"

  command {
    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    virtualenv --python=~{version} ~{name};

    source ~{name}/bin/activate;

    pip install -r ~{requirements};
  }

  output {
    File python = "${python_binary}"
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }
}

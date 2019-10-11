version 1.0
# -------------------------------------------------------------------------------------------------
# Commonly used basic unix commands
# -------------------------------------------------------------------------------------------------


task wget {
  input {
    String url
    String ? userString

    String sge_queue = "all.q"
    Float memory = 1
    Int cpu = 1
  }

  String filename = basename(url)

  command {
    wget ~{userString} ~{url} -O ~{filename}
  }

  output {
    File output_file = "~{filename}"
  }

  runtime {
    sge_queue: sge_queue
    memory: memory + " GB"
    cpu: cpu
  }
}

task mkdir {
  input {
    String directory
    String ? userString

    String sge_queue = "all.q"
    Float memory = 1
    Int cpu = 1
  }

  command {
    mkdir ~{default="-p " userString} ~{directory}
  }

  output {
    String output_directory = "~{directory}"
  }

  runtime {
    sge_queue: sge_queue
    memory: memory + " GB"
    cpu: cpu
  }
}

task mv {
  input {
    File input_file
    String target
    String ? userString

    String sge_queue = "all.q"
    Float memory = 1
    Int cpu = 1
  }

  command {
    mv ~{userString} ~{input_file} ~{target}
  }

  output {
    File output_file = "~{target}"
  }

  runtime {
    sge_queue: sge_queue
    memory: memory + " GB"
    cpu: cpu
  }
}

task cp {
  input {
    File input_file
    String target
    String ? userString

    String sge_queue = "all.q"
    Float memory = 1
    Int cpu = 1
  }

  command {
    cp ~{userString} ~{input_file} ~{target}
  }

  output {
    File output_file = "~{target}"
  }

  runtime {
    sge_queue: sge_queue
    memory: memory + " GB"
    cpu: cpu
  }
}

task Install {
  input {
    File input_file
    String mode = '755'
    String target
    String ? userString

    String sge_queue = "all.q"
    Float memory = 1
    Int cpu = 1
  }

  command {
    install -D ~{input_file} -m ~{mode} ~{userString} ~{target}
  }

  output {
    File output_file = "~{target}"
  }

  runtime {
    sge_queue: sge_queue
    memory: memory + " GB"
    cpu: cpu
  }
}

task UnZip {
  input {
    File input_file
    String ? userString
    String output_filename = basename(input_file, ".gz")

    String sge_queue = "all.q"
    Float memory = 1
    Int cpu = 1
  }

  command {
    gunzip -dc ~{userString} ~{input_file} > ~{output_filename}
  }

  output {
    File output_file = "~{output_filename}"
  }

  runtime {
    sge_queue: sge_queue
    memory: memory + " GB"
    cpu: cpu
  }
}

task BgZip {
  input {
    File ? bgzip
    File input_file
    String ? userString
    String output_filename = basename(input_file) + ".gz"

    Array[String] modules = []

    String sge_queue = "all.q"
    Float memory = 1
    Int cpu = 1
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="bgzip" bgzip} \
      -c ~{userString} \
      ~{input_file} > ~{output_filename};
  }

  output {
    File output_file = "~{output_filename}"
  }

  runtime {
    sge_queue: sge_queue
    memory: memory + " GB"
    cpu: cpu
  }
}

task Tabix {
  input {
    File ? tabix
    File input_file
    String userString = "-p vcf"
    String output_filename = input_file + ".tbi"

    Array[String] modules = []

    String sge_queue = "all.q"
    Float memory = 1
    Int cpu = 1
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
      module load $MODULE
    done;

    ~{default="tabix" tabix} \
      ~{userString} \
      ~{input_file};
  }

  output {
    File output_file = "~{output_filename}"
  }

  runtime {
    sge_queue: sge_queue
    memory: memory + " GB"
    cpu: cpu
  }
}

task CompressAndIndex {
  input {
    File ? bgzip
    File ? tabix
    File input_file

    String ? bgzipParams
    String tabixParams = "-p vcf"
    String output_filename = basename(input_file) + ".gz"
    String output_idx_filename = basename(input_file) + ".gz.tbi"

    Array[String] modules = []

    String sge_queue = "all.q"
    Float memory = 1
    Int cpu = 1
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="bgzip" bgzip} \
      -c ~{bgzipParams} \
      ~{input_file} > ~{output_filename};

    ~{default="tabix" tabix} \
      ~{tabixParams} \
      ~{output_filename};
  }

  output {
    File output_file = "~{output_filename}"
    File output_idx_file = "~{output_idx_filename}"
  }

  runtime {
    sge_queue: sge_queue
    memory: memory + " GB"
    cpu: cpu
  }
}

task cut {
  input {
    File input_file
    String output_filename

    String fields
    String ? delimiter
    String ? userString

    String sge_queue = "all.q"
    Float memory = 1
    Int cpu = 1
  }

  command {
    cut ~{userString} ~{"-d " + delimiter} -f ~{fields} > ~{output_filename}
  }

  output {
    File output_file = "~{output_filename}"
  }

  runtime {
    sge_queue: sge_queue
    memory: memory + " GB"
    cpu: cpu
  }
}

task sort {
  input {
    File input_file
    String output_filename

    String ? userString

    String sge_queue = "all.q"
    Float memory = 1
    Int cpu = 1
  }

  command {
    sort ~{userString} ~{input_file} > ~{output_filename}
  }

  output {
    File output_file = "~{output_filename}"
  }

  runtime {
    sge_queue: sge_queue
    memory: memory + " GB"
    cpu: cpu
  }
}

task cat {
	input {
		File input_file
    String output_filename

		Array[String] ? input_files
		String ? userString

    String sge_queue = "all.q"
    Float memory = 1
    Int cpu = 1
	}

	command {
		cat ~{userString} ~{input_file} ~{sep=" " input_files} > ~{output_filename}
	}

	output {
		File output_file = "~{output_filename}"
	}

  runtime {
    sge_queue: sge_queue
    memory: memory + " GB"
    cpu: cpu
  }
}

task sed {
  input {
    File input_file
    String output_filename
    String command

    String sge_queue = "all.q"
    Float memory = 1
    Int cpu = 1
  }

  command {
    sed ~{command} ~{input_file} > ~{output_filename}
  }

  output {
    File output_file = "~{output_filename}"
  }

  runtime {
    sge_queue: sge_queue
    memory: memory + " GB"
    cpu: cpu
  }
}

task tar {
  input {
    Array[String] input_files
    String output_filename
    String userString = "-zcvf"

    String sge_queue = "all.q"
    Float memory = 1
    Int cpu = 1
  }

  command {
    tar ~{userString} ~{output_filename} ~{sep=" " input_files}
  }

  output {
    File output_file = "~{output_filename}"
  }

  runtime {
    sge_queue: sge_queue
    memory: memory + " GB"
    cpu: cpu
  }
}

task grep {
	input {
		File input_file
    String output_filename
		String ? userString

    String sge_queue = "all.q"
    Float memory = 1
    Int cpu = 1
	}

	command {
		grep ~{userString} ~{input_file} > ~{output_filename}
	}

	output {
		File output_file = "~{output_filename}"
	}

  runtime {
    sge_queue: sge_queue
    memory: memory + " GB"
    cpu: cpu
  }
}

task zgrep {
	input {
		File input_file
    String output_filename
		String ? userString

    String sge_queue = "all.q"
    Float memory = 1
    Int cpu = 1
	}

	command {
		zgrep ~{userString} ~{input_file} > ~{output_filename}
	}

	output {
		File output_file = "~{output_filename}"
	}

  runtime {
    sge_queue: sge_queue
    memory: memory + " GB"
    cpu: cpu
  }
}

version 1.0
# -------------------------------------------------------------------------------------------------
# Commonly used basic unix commands
# -------------------------------------------------------------------------------------------------
task wget {
  input {
    String url
    String ? userString
  }

  String filename = basename(url)

  command {
    wget ${userString} ${url} -O ${filename}
  }

  output {
    File output_file = "${filename}"
  }
}

task mkdir {
  input {
    String directory
    String ? userString
  }

  command {
    mkdir ${default="-p " userString} ${directory}
  }

  output {
    String output_directory = "${directory}"
  }
}

task mv {
  input {
    File input_file
    String target
    String ? userString
  }

  command {
    mv ${userString} ${input_file} ${target}
  }

  output {
    File output_file = "${target}"
  }
}

task cp {
  input {
    File input_file
    String target
    String ? userString
  }

  command {
    cp ${userString} ${input_file} ${target}
  }

  output {
    File output_file = "${target}"
  }
}

task UnZip {
  input {
    File input_file
    String ? userString
  }

  String output_filename = basename(input_file, ".gz")

  command {
    gunzip -dc ${userString} ${input_file} > ${output_filename}
  }

  output {
    File output_file = "${output_filename}"
  }
}

task BgZip {
  input {
    File ? bgzip
    File input_file
    String ? userString
  }

  String output_filename = basename(input_file) + ".gz"

  command {
    ${default="bgzip" bgzip} -c ${userString} ${input_file} > ${output_filename}
  }

  output {
    File output_file = "${output_filename}"
  }
}

task Tabix {
  input {
    File ? tabix
    File input_file
    String ? userString
  }

  String output_filename = input_file + ".tbi"

  command {
    ${default="tabix" tabix} ${default="-p vcf" userString} ${input_file}
  }

  output {
    File output_file = "${output_filename}"
  }
}

task CompressAndIndex {
  input {
    File ? bgzip
    File ? tabix
    File input_file

    String ? bgzipParams
    String ? tabixParams
  }

  String output_filename = basename(input_file) + ".gz"
  String output_idx_filename = basename(input_file) + ".gz.tbi"

  command {
    set -Eeuxo pipefail;
    ${default="bgzip" bgzip} -c ${bgzipParams} ${input_file} > ${output_filename};
    ${default="tabix" tabix} ${default="-p vcf" tabixParams} ${output_filename};
  }

  output {
    File output_file = "${output_filename}"
    File output_idx_file = "${output_idx_filename}"
  }
}

version 1.0

task ValidateSamFile {
  input {
    File ? java
    File picard

    File input_file
    File input_idx_file
    String filename_prefix

    File reference
    File reference_idx
    File reference_dict

    String validation_stringency = "LENIENT"
    String userString = "IGNORE=MISSING_TAG_NM"

    Array[String] modules = []
    Float memory = 16
    Int cpu = 1
  }

  Int jvm_memory = round(memory)
  String output_filename = filename_prefix + ".validation_report.txt"

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="java" java} \
      -Xmx~{jvm_memory}g \
      -jar ~{default="picard" picard} ValidateSamFile \
      INPUT=~{input_file} \
      OUTPUT=~{output_filename} \
      REFERENCE_SEQUENCE=~{reference} \
      MODE=VERBOSE \
      ~{userString} \
      VALIDATION_STRINGENCY=~{validation_stringency};

  }

  output {
    File validate_sam_report = "~{output_filename}"
  }

  runtime {
    memory: jvm_memory * 1.5 + " GB"
    cpu: cpu
  }

  parameter_meta {
    java: "Path to Java."
    picard: "Picard jar file."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    reference_dict: "Reference sequence dictionary (.dict)."
    filename_prefix: "prefix for output files."
    input_file: "Sorted SAM/BAM/CRAM file."
    input_idx_file: "Sorted SAM/BAM/CRAM index file."
    validation_stringency: "Validation stringency for all SAM files read by this program. Setting stringency to SILENT can improve performance when processing a BAM file in which variable-length data (read, qualities, tags) do not otherwise need to be decoded."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    picard_version: "2.19.0"
    version: "0.1.0"
  }
}

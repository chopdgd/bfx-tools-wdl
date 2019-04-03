version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://broadinstitute.github.io/picard/
# Task Summary: Add/replace read groups in a BAM file.
# Tool Name: Picard AddOrReplaceReadGroups
# Documentation: https://broadinstitute.github.io/picard/command-line-overview.html#AddOrReplaceReadGroups
# -------------------------------------------------------------------------------------------------


task AddOrReplaceReadGroups {
  input {
    File ? java
    File ? picard

    File input_bam
    String sample_id
    String output_filename_extension

    Int RGID = 4
    String RGLB = "lib1"
    String RGPL = "illumina"
    String RGPU = "unit1"
    String RGSM = "20"

    String ? userString

    Array[String] modules = []
    Int memory = 4
    Int cpu = 1
  }

  String output_filename = "${sample_id}" + "${output_filename_extension}"

  command {
    set -Eeuxo pipefail;

    for MODULE in ${sep=' ' modules}; do
        module load $MODULE
    done;

    ${default="java" java} \
      -Xmx${memory}g \
      -jar ${default="picard" picard} AddOrReplaceReadGroups \
      ${userString} \
      I=${input_bam} \
      O=${output_filename} \
      RGID=${RGID} \
      RGLB=${RGLB} \
      RGPL=${RGPL} \
      RGPU=${RGPU} \
      RGSM=${RGSM};
  }

	output {
		File output_bam = "${output_filename}"
	}

	runtime {
		memory: memory * 1.5 + " GB"
		cpu: cpu
	}

	parameter_meta {
    java: "Path to Java."
    picard: "Picard jar file."
    input_bam: "Sorted BAM file."
    sample_id: "prefix for output files."
    output_filename_extension: "Full BAM filename with extension change, e.g. .rg.bam"
    RGID: "Read Group ID."
    RGLB: "Read Group library."
    RGPL: "Read Group platform."
    RGPU: "Read Group platform unit."
    RGSM: "Read Group sample name."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    modules: "Modules to load when task is called; modules must be compatible with the platform the task runs on."
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

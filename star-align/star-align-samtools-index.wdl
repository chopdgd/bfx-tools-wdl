version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/alexdobin/STAR
#               http://www.htslib.org/
# Task Summary: Spliced transcript alignment to a reference, then .bai generation with SAMTools
# Tool Name: STAR-Align & SAMTools
# Documentation: https://github.com/alexdobin/STAR/blob/master/doc/STARmanual.pdf
#                http://www.htslib.org/doc/samtools.html
# -------------------------------------------------------------------------------------------------

task STARAlignSamToolsIndex {
  input {
    File ? staralign
    File ? samtools
    String sample_id

    File fastq_1
    File fastq_2
    String reference_directory

    String readFilesCommand = "zcat"
    String outSAMattributes = "NH HI AS NM MD"
    String outSAMunmapped = "Within"
    String outFilterType = "BySJout"
    String alignSJstitchMismatchNmax = "5 -1 5 5"

    Int alignIntronMin = 20
    Int alignIntronMax = 1000000
    Int alignMatesGapMax = 1000000
    Int alignSJDBoverhangMin = 1
    Int alignSJoverhangMin = 8
    Int chimSegmentMin = 12
    Int chimSegmentReadGapMax = 3
    Int chimJunctionOverhangMin = 12
    Int sjdbScore = 1
    Int outFilterMultimapNmax = 20
    Int outFilterMismatchNmax = 999
    Float outFilterMismatchNoverReadLmax = 0.04
    String ? userString

    Array[String] modules = []
    Float memory = 48
    Int cpu = 12
  }

  command {
    set -Eeuxo pipefail;

    for MODULE in ~{sep=' ' modules}; do
        module load $MODULE
    done;

    ~{default="STAR" staralign} \
      --runMode alignReads \
      --genomeDir ~{reference_directory} \
      --readFilesIn ~{fastq_1} ~{fastq_2} \
      --readFilesCommand ~{readFilesCommand} \
      --outSAMattributes ~{outSAMattributes} \
      --outSAMunmapped ~{outSAMunmapped} \
      --outFilterType ~{outFilterType} \
      --alignSJstitchMismatchNmax ~{alignSJstitchMismatchNmax} \
      --alignIntronMin ~{alignIntronMin} \
      --alignIntronMax ~{alignIntronMax} \
      --alignMatesGapMax ~{alignMatesGapMax} \
      --alignSJDBoverhangMin ~{alignSJDBoverhangMin} \
      --alignSJoverhangMin ~{alignSJoverhangMin} \
      --chimSegmentMin ~{chimSegmentMin} \
      --chimSegmentReadGapMax ~{chimSegmentReadGapMax} \
      --chimJunctionOverhangMin ~{chimJunctionOverhangMin} \
      --sjdbScore ~{sjdbScore} \
      --outFilterMultimapNmax ~{outFilterMultimapNmax} \
      --outFilterMismatchNmax ~{outFilterMismatchNmax} \
      --outFilterMismatchNoverReadLmax ~{outFilterMismatchNoverReadLmax} \
      --runThreadN ~{cpu} \
      --quantMode TranscriptomeSAM GeneCounts \
      --outSAMtype BAM SortedByCoordinate \
      --chimOutJunctionFormat 1 \
      --chimOutType WithinBAM SoftClip \
      ~{userString} \
      --twopassMode Basic;


    ~{default="samtools" samtools} sort \
      -@ ~{cpu} \
      -O BAM \
      -o Aligned.toTranscriptome.sorted.bam \
      Aligned.toTranscriptome.out.bam

    ~{default="samtools" samtools} index \
      -@ ~{cpu} \
      Aligned.sortedByCoord.out.bam \
      Aligned.sortedByCoord.out.bam.bai;

    ~{default="samtools" samtools} index \
      -@ ~{cpu} \
      Aligned.toTranscriptome.sorted.bam \
      Aligned.toTranscriptome.sorted.bam.bai;

    mv Aligned.sortedByCoord.out.bam ~{sample_id}.star-align.sorted.bam;
    mv Aligned.sortedByCoord.out.bam.bai ~{sample_id}.star-align.sorted.bam.bai;
    mv Aligned.toTranscriptome.sorted.bam ~{sample_id}.star-align.transcriptome.sorted.bam;
    mv Aligned.toTranscriptome.sorted.bam.bai ~{sample_id}.star-align.transcriptome.sorted.bam.bai;
  }

  output {
    File bam_file = "~{sample_id}" + '.star-align.sorted.bam'
    File bam_idx_file = "~{sample_id}" + '.star-align.sorted.bam.bai'
    File transcriptome_bam_file = "~{sample_id}" + '.star-align.transcriptome.sorted.bam'
    File transcriptome_bam_idx_file = "~{sample_id}" + '.star-align.transcriptome.sorted.bam.bai'
  }

  runtime {
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    staralign: "Path to STAR binary."
    sample_id: "Prefix for output files."
    reference_directory: "Directory where the STAR reference index was created using STAR --genomeGenerate."
    readFilesCommand: "Shell command to read the fastqs in, e.g. zcat if fastqs are compressed."
    outSAMattributes: "Desired SAM attributes in desired order."
    outSAMunmapped: "Output of unmapped readed in SAM format."
    outFilterType: "Type of filtering to use."
    alignIntronMin: "Min intron size."
    alignIntronMax: "Max intron size."
    alignMatesGapMax: "Maximum gap between two mates."
    alignSJDBoverhangMin: "Minimum overhang for annotated spliced alignments."
    alignSJoverhangMin: "Minimum overhang for spliced alignments."
    chimSegmentMin: "Minimum length of chimeric segment length."
    chimJunctionOverhangMin: "Minimum overhang for chimeric junction."
    userString: "An optional parameter which allows the user to specify additions to the command line at run time."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    STAR_version: "2.6.1c"
    version: "0.2.0"
  }
}

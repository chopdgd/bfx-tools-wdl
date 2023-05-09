version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/STAR-Fusion/STAR-Fusion
#               http://www.htslib.org/
# Task Summary: Leverages STAR aligner to identify candidate fusion transcripts; sort and index with SAMTools
# Tool Name: STAR-Fusion & SAMTools
# Documentation: https://github.com/STAR-Fusion/STAR-Fusion/wiki
#                http://www.htslib.org/doc/samtools.html
# -------------------------------------------------------------------------------------------------

task STARFusionSamToolsSortIndex {
  input {
    File fastq_1
    File fastq_2
    String sample_id
    String reference_directory

    String userString = "--examine_coding_effect"

    File image
    Float memory = 48
    Int cpu = 12
  }

  command {
    set -Eeuxo pipefail;

    /usr/local/src/STAR-Fusion/STAR-Fusion \
      --genome_lib_dir ~{reference_directory} \
      ~{userString} \
      --left_fq ~{fastq_1} \
      --right_fq ~{fastq_2} \
      --CPU ~{cpu};

    samtools sort \
      -@ ~{cpu} \
      -O bam \
      -o STAR-Fusion_outdir/Aligned.out.sorted.bam \
      STAR-Fusion_outdir/Aligned.out.bam;

    samtools index \
      -@ ~{cpu} \
      STAR-Fusion_outdir/Aligned.out.sorted.bam \
      STAR-Fusion_outdir/Aligned.out.sorted.bam.bai;

    mv STAR-Fusion_outdir/Aligned.out.sorted.bam STAR-Fusion_outdir/~{sample_id}.star-fusion.sorted.bam
    mv STAR-Fusion_outdir/Aligned.out.sorted.bam.bai STAR-Fusion_outdir/~{sample_id}.star-fusion.sorted.bam.bai
  }

  output {
    File bam_file = 'STAR-Fusion_outdir/' + "~{sample_id}" + '.star-fusion.sorted.bam'
    File bam_idx_file = 'STAR-Fusion_outdir/' + "~{sample_id}" + '.star-fusion.sorted.bam.bai'
    File fusion_coding_effect = 'STAR-Fusion_outdir/star-fusion.fusion_predictions.abridged.coding_effect.tsv'
    File fusion_preliminary = 'STAR-Fusion_outdir/star-fusion.preliminary/star-fusion.fusion_candidates.preliminary'
  }

  runtime {
    singularity: true
    image: image
    memory: memory + " GB"
    cpu: cpu
  }

  parameter_meta {
    reference_directory: "Fusion genome reference directory."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Mark Welsh"
    email: "welshm3@email.chop.edu"
    STAR_fusion_version: "1.5.0"
    version: "0.4.0"
  }
}

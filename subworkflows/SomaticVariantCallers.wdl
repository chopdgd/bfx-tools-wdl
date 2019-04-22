version 1.0
# -------------------------------------------------------------------------------------------------
# Workflow Summary: Variant callers for germline cancer workflows
# Tools used:
#  + FreeBayes
#  + MuTect
#  + Pindel for tandem duplications
#  + VarScan
#  + Scalpel
# -------------------------------------------------------------------------------------------------

import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/freebayes/FreeBayes.wdl" as FreeBayes
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/mutect/MuTect.wdl" as MuTect
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/pindel/Pindel.wdl" as Pindel
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/pindel/Pindel2VCF.wdl" as Pindel2Vcf
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/samtools/MPileup.wdl" as Samtools
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/varscan/VarScan.wdl" as VarScan
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/scalpel/Single.wdl" as Scalpel

workflow VariantCaller {
  input {
    String sample_id
    File bam_file
    File bam_idx_file

    File intervals  # NOTE: This should be in BED format, so all tools could use
    File pindel_intervals

    File ? java17  # NOTE: MuTect v1 requires java 1.7
    File ? java
    File ? freebayes
    File ? mutect
    File ? pindel
    File ? pindel2vcf
    File ? samtools
    File ? varscan
    # NOTE: The reason for making this a string is because we want to avoid linking the file.
    # It required a bunch of Perl modules found alongside the script
    String scalpel

    File reference
    File reference_idx
    File reference_dict

    File ? dbsnp
    File ? dbsnp_idx
  }

  call FreeBayes.FreeBayes {
    input:
      freebayes=freebayes,
      reference=reference,
      reference_idx=reference_idx,
      intervals=intervals,
      sample_id=sample_id,
      bam_file=bam_file,
      bam_idx_file=bam_idx_file,
  }

  call MuTect.MuTect {
    input:
      java=java17,
      mutect=mutect,
      reference=reference,
      reference_idx=reference_idx,
      reference_dict=reference_dict,
      dbsnp=dbsnp,
      dbsnp_idx=dbsnp_idx,
      intervals=[intervals],
      sample_id=sample_id,
      bam_file=bam_file,
      bam_idx_file=bam_idx_file,
  }

  call Pindel.Pindel {
    input:
      pindel=pindel,
      reference=reference,
      reference_idx=reference_idx,
      intervals=pindel_intervals,
      sample_id=sample_id,
      bam_file=bam_file,
      bam_idx_file=bam_idx_file,
  }

  call Pindel2Vcf.Pindel2Vcf {
    input:
      pindel2vcf=pindel2vcf,
      reference=reference,
      reference_idx=reference_idx,
      input_file=Pindel.tandem_duplication_file,
  }

  call Samtools.MPileup {
    input:
      samtools=samtools,
      reference=reference,
      reference_idx=reference_idx,
      bam_files=[bam_file],
      bam_idx_files=[bam_idx_file],
      intervals=intervals,
  }

  call VarScan.MPileup2CNS {
    input:
      java=java,
      varscan=varscan,
      sample_id=sample_id,
      mpileup=MPileup.mpileup_file,
  }

  call Scalpel.Single {
    input:
      scalpel=scalpel,
      reference=reference,
      reference_idx=reference_idx,
      intervals=intervals,
      sample_id=sample_id,
      bam_file=bam_file,
      bam_idx_file=bam_idx_file,
  }

  output {
    File freebayes_vcf_file = FreeBayes.vcf_file
    File mutect_vcf_file = MuTect.vcf_file
    File mutect_vcf_file_idx = MuTect.vcf_idx_file
    File mutect_stats_file = MuTect.stats_file
    File mutect_coverage_file = MuTect.coverage_file
    File pindel_vcf_file = Pindel2Vcf.vcf_file
    File varscan_vcf_file = MPileup2CNS.vcf_file
    File scalpel_vcf_file = Single.vcf_file
  }

  parameter_meta {
    sample_id: "prefix for output files."
    bam_file: "Sorted and duplicate marked BAM file."
    bam_idx_file: "BAM file index (.bai)."
    intervals: "One or more genomic intervals over which to operate (Should be in BED format)."
    java: "Path to Java."
    freebayes: "FreeBayes executable."
    mutect: "MuTect v1 jar file."
    pindel: "pindel executable."
    pindel2vcf: "pindel2vcf executable."
    samtools: "Samtools executable."
    varscan: "VarScan Jar file."
    scalpel: "Scalpel executable."
    reference: "Reference sequence file."
    reference_idx: "Reference sequence index (.fai)."
    reference_dict: "Reference sequence dict (.dict)."
    dbsnp: "dbSNP VCF file."
    dbsnp_idx: "dbSNP VCF index file (.tbi)."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    version: "0.1.0"
  }
}

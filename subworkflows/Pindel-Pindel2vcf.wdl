version 1.0
# -------------------------------------------------------------------------------------------------
# Workflow Summary: FASTQ to BAM pipeline using NovoAlign, Samtools, and Picard
# Tools Used:
#  * Pindel
#  * pindel2vcf
# -------------------------------------------------------------------------------------------------

 import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/feature-pindel2vcf-formito/pindel/Pindel.wdl" as PindelCNVCalling
 import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/feature-pindel2vcf-formito/pindel/Pindel2VCF_4Mito.wdl" as Pindel2VCF4Mito

workflow FastQToBAM {
  input {
    String sample_id
    
    File ? pindel
    File pindel2vcf

    File bam_file
    File bam_idx_file

    File reference
    File reference_idx
    String reference_version
    String reference_date
    
    Int pindel_sliding_window
    String ? pindel2vcf_userString

  }

  call PindelCNVCalling.Pindel as PindelCNV {
    input:
      pindel=pindel,
      reference=reference,
      reference_idx=reference_idx,
      sample_id=sample_id,
      bam_file=bam_file,
      bam_idx_file=bam_idx_file,
      userString="-T 5 -H 3 -E 0.99 -s -v 10 -x 6 -l -k -C ",
      sliding_window=pindel_sliding_window
  }

  call Pindel2VCF4Mito.Pindel2VCF4Mito as Pindel2VCF {
    input:
      sample_id_cnv=PindelCNV.deletion_file,
      pindel2vcf=pindel2vcf,
      reference=reference,
      reference_idx=reference_idx,
      reference_version=reference_version,
      reference_date=reference_date,
      userString="-sb -ss 3 -G ",
  }

  output {
    Array[Array[File]] pindel_vcf_files = [
        Pindel2VCF.vcf_file,
      ]
  }

  parameter_meta {
    sample_id: "Sample ID to use in SAM TAG."
    reference: "Directory for circular reference."
    pindel: "pindel executable."
    pindel2VCF: "the pindel2vcf script."
    pindel_sliding_window: "average size of inserts used."
  }

  meta {
    author: "Michael A. Gonzalez"
    email: "GonzalezMA@email.chop.edu"
    version: "0.1.0"
  }
}

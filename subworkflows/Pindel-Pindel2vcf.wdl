version 1.0
# -------------------------------------------------------------------------------------------------
# Workflow Summary: CNV calling from circular alignment pipeline using Pindel and pindel2vcf tools
# Tools Used:
#  * Pindel
#  * pindel2vcf
# -------------------------------------------------------------------------------------------------

import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/feature-pindel2vcf-formito/pindel/Pindel2VCF_4Mito.wdl" as Pindel2VCF4Mito

workflow PindelCNV {
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

    String pindel_userString
    String ? pindel2vcf_userString
  }


  call Pindel2VCF4Mito.PindelCNV2VCF4Mito as PindelCNV2VCF {
    input:
      sample_id=sample_id,
      pindel=pindel,
      pindel2vcf=pindel2vcf,
      reference=reference,
      reference_idx=reference_idx,
      reference_version=reference_version,
      reference_date=reference_date,
      pindel_userString="-T 5 -H 3 -E 0.99 -s -v 10 -x 6 -l -k -C ",
      pindel2vcf_userString="-sb -ss 3 -G ",
      sliding_window=pindel_sliding_window
  }


  output {
    Array[File] pindel_vcf_files = [
        PindelCNV2VCF.vcf_file,
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
    author: "Pushkala Jayaraman"
    email: "jayaramanp@email.chop.edu"
    version: "0.1.0"
  }
}

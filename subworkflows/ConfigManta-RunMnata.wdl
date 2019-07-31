version 1.0
# -------------------------------------------------------------------------------------------------
# Package Name: https://github.com/Illumina/manta
# Task Summary: Manta calls structural variants (SVs) and indels from mapped paired-end sequencing reads. It is optimized for analysis of germline variation in small sets of individuals and somatic variation in tumor/normal sample pairs.
# Tool Name: Manta
# Documentation: https://github.com/Illumina/manta/tree/master/docs
# -------------------------------------------------------------------------------------------------

import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/feature_mitoCNVcalling_manta/manta/ConfigAndRunManta.wdl" as MantaConfigAndCNVCalling

import "https://github.research.chop.edu/raw/DGD/dgd-wdl-workflows/feature_mito_cnv_alignment_subworkflow/tasks/inhouse/remap-manta-results.wdl" as MantaRemappedVCF


workflow ConfigMantaRunManta{
  
  input {
    String ? python
    File ? manta

    File reference
    File ? reference_idx

    String sample_id
    String test_code

    File bam_file
    File bam_idx_file

    String ? userString

    Array[String] modules = []
    Float memory = 4
    Int cpu = 1
  }

  call MantaConfigAndCNVCalling.ConfigRunManta as RunManta {
    input:
      python=python,
      manta=manta,
      reference=reference,
      reference_idx=reference_idx,
      sample_id=sample_id,
      bam_file=bam_file,
      userString=userString,
      bam_idx_file=bam_idx_file
   }

  call MantaRemappedVCF.RemapVCF {
    input:
      python=python,
      remap_manta_python=remap_manta_vcf_python,
      sample_id=sample_id,
      shifted_ref_vcf=RunManta.vcfFile,
      test_code=test_code
   }

  output {
    Array[Array[File]] manta_vcf_files = [
        RunManta.vcfFile,
     ]
    Array[Array[File]] manta_remapped_vcf_files = [
        RemapVCF.manta_remapped_VCF,
     ]
  
  }

  parameter_meta {
    manta: "manta Config executable."
    reference: "reference file."
    reference_idx: "reference idx."
    sample_id: "sample id."
    bam_file: "BAM file."
    bam_idx_file: "BAM index file."
    memory: "GB of RAM to use at runtime."
    cpu: "Number of CPUs to use at runtime."
  }

  meta {
    author: "Pushkala Jayaraman"
    email: "jayaramanp@email.chop.edu"
    pindel_version: "1.4.0"
    version: "0.1.0"
  }
}

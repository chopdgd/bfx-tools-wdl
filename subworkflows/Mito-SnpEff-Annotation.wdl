version 1.0
# -------------------------------------------------------------------------------------------------
# Workflow Summary: Annotate Mito VCF with SnpEff and various databases using SnpSift
# Tools Used:
#  * SnpEff
#  * SnpSift -- snpsift version is 4.2 in the production pipeline
# -------------------------------------------------------------------------------------------------
# BFX Tools
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/unix/commands.wdl" as Unix
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/vt/DecomposeAndNormalize.wdl" as DecomposeNormalizeVCF
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/vt/DecomposeBlockSubstitutions.wdl" as DecomposeBlockSubstitutions
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/snpeff/SnpEff.wdl" as SnpEff
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/develop/snpeff/SnpSift.wdl" as SnpSift

workflow MitoAnnotation {
  input {
    # Tools
    File ? java
    File ? snpeff
    File ? snpsift
    File ? bgzip
    File ? tabix
    File snpeff_config
    File snpeff_dataDir

    # Inputs
    File input_file
    String sample_id
    String reference_version

    # Resources
    File mitomap_poly
    File ? mitomap_poly_idx
    File mitomap_disease
    File ? mitomap_disease_idx
    File rcrs_vcf
    File ? rcrs_vcf_idx
  }

  call SnpEff.SnpEff {
    input:
      java=java,
      snpeff=snpeff,
      config=snpeff_config,
      dataDir=snpeff_dataDir,
      filename_prefix=sample_id,
      reference_version=reference_version,
      input_file=input_file,
  }

  call SnpSift.SnpSift as SnpSift_mitomap_poly {
    input:
      java=java,
      snpsift=snpsift,
      config=snpeff_config,
      filename_prefix=sample_id,
      database=mitomap_poly,
      database_idx=mitomap_poly_idx,
      input_file=SnpEff.vcf_file,
  }

  call SnpSift.SnpSift as SnpSift_mitomap_disease {
    input:
      java=java,
      snpsift=snpsift,
      config=snpeff_config,
      filename_prefix=sample_id,
      database=mitomap_disease,
      database_idx=mitomap_disease_idx,
      input_file=SnpSift_mitomap_poly.vcf_file,
  }

  call SnpSift.SnpSift as Extract_rCRS_var {
    input:
      java=java,
      snpsift=snpsift,
      config=snpeff_config,
      filename_prefix=sample_id,
      database=rcrs_vcf,
      database_idx=rcrs_vcf_idx,
      input_file=SnpSift_mitomap_disease.vcf_file,
  }

  call Unix.CompressAndIndex {
    input:
      bgzip=bgzip,
      tabix=tabix,
      input_file=Extract_rCRS_var.vcf_file,
  }

  output {
    File vcf_file = CompressAndIndex.output_file
    File vcf_idx_file = CompressAndIndex.output_idx_file
  }
}

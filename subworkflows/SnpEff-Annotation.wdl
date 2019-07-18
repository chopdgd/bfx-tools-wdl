version 1.0
# -------------------------------------------------------------------------------------------------
# Workflow Summary: SnpEff and SnpSift to annotate a VCF with various public resources
# Tools Used:
#  * vt to decompose and normalize
#  * SnpEff
#  * SnpSift
# -------------------------------------------------------------------------------------------------

import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.0.0/vt/DecomposeAndNormalize.wdl" as VT
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.0.0/snpeff/SnpEff.wdl" as SnpEff
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.0.0/snpeff/SnpSift.wdl" as SnpSift
import "https://raw.githubusercontent.com/chopdgd/bfx-tools-wdl/v1.0.0/unix/commands.wdl" as Unix

workflow Annotation {
  input {
    File ? vt
    File ? bgzip
    File ? tabix
    File ? java
    File ? snpeff
    File ? snpsift
    File config
    File dataDir
    String ? reference_version

    File input_file
    File ? input_idx_file

    File reference
    File dbnsfp
    File dbnsfp_idx
    File exac
    File exac_idx
    File gnomad_exome
    File gnomad_exome_idx
    File gnomad_genome
    File gnomad_genome_idx
    File hgmd
    File hgmd_idx
    File clinvar
    File clinvar_idx
    File cosmic
    File cosmic_idx
  }

  call VT.DecomposeNormalizeVCF {
    input:
      vt=vt,
      reference=reference,
      input_file=input_file,
      input_idx_file=input_idx_file,
  }

  call SnpEff.SnpEff {
    input:
      java=java,
      snpeff=snpeff,
      config=config,
      dataDir=dataDir,
      reference_version=reference_version,
      filename_prefix='snpeff',
      input_file=DecomposeNormalizeVCF.vcf_file,
  }

  call SnpSift.SnpSift as dbNSFP {
    input:
      java=java,
      snpsift=snpsift,
      config=config,
      mode="dbnsfp",
      database=dbnsfp,
      database_idx=dbnsfp_idx,
      filename_prefix='dbnsfp',
      input_file=SnpEff.vcf_file,
  }

  call SnpSift.SnpSift as ExAC {
    input:
      java=java,
      snpsift=snpsift,
      config=config,
      mode="annotate",
      database=exac,
      database_idx=exac_idx,
      filename_prefix='exac',
      input_file=dbNSFP.vcf_file,
  }

  call SnpSift.SnpSift as gnomADExome {
    input:
      java=java,
      snpsift=snpsift,
      config=config,
      mode="annotate",
      database=gnomad_exome,
      database_idx=gnomad_exome_idx,
      filename_prefix='gnomad_exome',
      input_file=ExAC.vcf_file,
  }

  call SnpSift.SnpSift as gnomADGenome {
    input:
      java=java,
      snpsift=snpsift,
      config=config,
      mode="annotate",
      database=gnomad_genome,
      database_idx=gnomad_genome_idx,
      filename_prefix='gnomad_genome',
      input_file=gnomADExome.vcf_file,
  }

  call SnpSift.SnpSift as HGMD {
    input:
      java=java,
      snpsift=snpsift,
      config=config,
      mode="annotate",
      database=hgmd,
      database_idx=hgmd_idx,
      filename_prefix='hgmd',
      input_file=gnomADGenome.vcf_file,
  }

  call SnpSift.SnpSift as ClinVar {
    input:
      java=java,
      snpsift=snpsift,
      config=config,
      mode="annotate",
      database=clinvar,
      database_idx=clinvar_idx,
      filename_prefix='clinvar',
      input_file=HGMD.vcf_file,
  }

  call SnpSift.SnpSift as COSMIC {
    input:
      java=java,
      snpsift=snpsift,
      config=config,
      mode="annotate",
      database=cosmic,
      database_idx=cosmic_idx,
      filename_prefix='cosmic',
      input_file=ClinVar.vcf_file,
  }

  call Unix.CompressAndIndex {
    input:
      bgzip=bgzip,
      tabix=tabix,
      input_file=COSMIC.vcf_file,
  }

  output {
    File vcf_file = CompressAndIndex.output_file
    File vcf_idx_file = CompressAndIndex.output_idx_file
  }
}

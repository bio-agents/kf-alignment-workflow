cwlVersion: v1.0
class: Workflow
id: kfdrc_cram_reheader
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  input_cram: File
  biospecimen_name: string
  output_basename: string
  indexed_reference_fasta: File
  dbsnp_vcf: File
  reference_dict: File
  contamination_sites_bed: File
  contamination_sites_mu: File
  contamination_sites_ud: File
  wgs_calling_interval_list: File
  wgs_coverage_interval_list: File
  wgs_evaluation_interval_list: File

outputs:
  cram: {type: File, outputSource: samagents_bam_to_cram_dev/output}
  gvcf: {type: File, outputSource: picard_mergevcfs/output}
  verifybamid_output: {type: File, outputSource: verifybamid/output}
  gvcf_calling_metrics: {type: 'File[]', outputSource: picard_collectgvcfcallingmetrics/output}
  aggregation_metrics: {type: 'File[]', outputSource: picard_collectaggregationmetrics/output}
  wgs_metrics: {type: File, outputSource: picard_collectwgsmetrics/output}

steps:
  samagents_cram_reheader:
    run: ../agents/samagents_cram_reheader.cwl
    in:
      input_cram: input_cram
      base_file_name: biospecimen_name
      output_basename: output_basename
      reference: indexed_reference_fasta
    out: [output]
 
  samagents_bam_to_cram_dev:
    run: ../agents/samagents_bam_to_cram_dev.cwl
    in:
      input_bam: samagents_cram_reheader/output
      reference: indexed_reference_fasta
      output_basename: output_basename
    out: [output]

  picard_collectaggregationmetrics:
    run: ../agents/picard_collectaggregationmetrics.cwl
    in:
      input_bam: samagents_cram_reheader/output
      reference: indexed_reference_fasta
    out: [output]

  picard_collectwgsmetrics:
    run: ../agents/picard_collectwgsmetrics.cwl
    in:
      input_bam: samagents_cram_reheader/output
      intervals: wgs_coverage_interval_list
      reference: indexed_reference_fasta
    out: [output]

  picard_intervallistagents:
    run: ../agents/picard_intervallistagents.cwl
    in:
      interval_list: wgs_calling_interval_list
    out: [output]

  verifybamid:
    run: ../agents/verifybamid.cwl
    in:
      contamination_sites_bed: contamination_sites_bed
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_ud: contamination_sites_ud
      input_bam: samagents_cram_reheader/output
      ref_fasta: indexed_reference_fasta
      output_basename: output_basename
    out: [output]

  checkcontamination:
    run: ../agents/expression_checkcontamination.cwl
    in:
      verifybamid_selfsm: verifybamid/output
    out: [contamination]

  gatk_haplotypecaller:
    run: ../agents/gatk_haplotypecaller.cwl
    in:
      contamination: checkcontamination/contamination
      input_bam: samagents_cram_reheader/output
      interval_list: picard_intervallistagents/output
      reference: indexed_reference_fasta
    scatter: [interval_list]
    out: [output]

  picard_mergevcfs:
    run: ../agents/picard_mergevcfs.cwl
    in:
      input_vcf: gatk_haplotypecaller/output
      output_vcf_basename: output_basename
    out: [output]

  picard_collectgvcfcallingmetrics:
    run: ../agents/picard_collectgvcfcallingmetrics.cwl
    in:
      dbsnp_vcf: dbsnp_vcf
      final_gvcf_base_name: output_basename
      input_vcf: picard_mergevcfs/output
      reference_dict: reference_dict
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:AWSInstanceType'
    value: c4.8xlarge;ebs-gp2;850
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4

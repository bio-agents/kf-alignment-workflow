cwlVersion: v1.0
class: Workflow
id: kfdrc_alignment_pipeline
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
inputs:
  input_bam: File
  output_basename: string
  indexed_reference_fasta: File
  contamination_sites_ud: File
  contamination_sites_mu: File
  contamination_sites_bed: File
  knownsites: File[]
  wgs_coverage_interval_list: File
  wgs_calling_interval_list: File
  reference_dict: File
  wgs_evaluation_interval_list: File
  dbsnp_vcf: File

outputs:
  bqsr_report: {type: File, outputSource: gatk_gatherbqsrreports/output}
  final_bam: {type: File, outputSource: picard_gatherbamfiles/output}
  gvcf: {type: File, outputSource: picard_mergevcfs/output}
  cram: {type: File, outputSource: samagents_coverttocram/output}
  verifybamid_output: {type: File, outputSource: verifybamid/output}
  collect_quality_yield_metrics: {type: 'File[]', outputSource: picard_collectqualityyieldmetrics/output}
  collect_collect_aggregation_metrics: {type: 'File[]', outputSource: picard_collectaggregationmetrics/output}
  collect_wgs_metrics: {type: File, outputSource: picard_collectwgsmetrics/output}
  calculate_readgroup_checksum: {type: File, outputSource: picard_calculatereadgroupchecksum/output}
  collect_readgroupbam_quality_metrics: {type: 'File[]', outputSource: picard_collectreadgroupbamqualitymetrics/output}
  picard_collect_gvcf_calling_metrics: {type: 'File[]', outputSource: picard_collectgvcfcallingmetrics/output}

steps:
  picard_revertsam:
    run: ../agents/picard_revertsam.cwl
    in:
      input_bam: input_bam
      reference: indexed_reference_fasta
    out: [output]

  picard_collectqualityyieldmetrics:
    run: ../agents/picard_collectqualityyieldmetrics.cwl
    in:
      input_bam: picard_revertsam/output
      output_basename: output_basename
    scatter: [input_bam]
    out: [output]

  bwa_mem:
    run: ../agents/bwa_mem.cwl
    in:
      indexed_reference_fasta: indexed_reference_fasta
      input_bam: picard_revertsam/output
    scatter: [input_bam]
    out: [output]

  picard_markduplicates:
    run: ../agents/picard_markduplicates.cwl
    in:
      base_file_name: output_basename
      input_bams: bwa_mem/output
    out: [output_markduplicates_bam]

  picard_sortsam:
    run: ../agents/picard_sortsam.cwl
    in:
      base_file_name: output_basename
      input_bam: picard_markduplicates/output_markduplicates_bam
    out: [output_sorted_bam]

  verifybamid:
    run: ../agents/verifybamid.cwl
    in:
      input_bam: picard_sortsam/output_sorted_bam
      ref_fasta: indexed_reference_fasta
      contamination_sites_ud: contamination_sites_ud
      contamination_sites_mu: contamination_sites_mu
      contamination_sites_bed: contamination_sites_bed
      output_basename: output_basename
    out: [output]

  createsequencegrouping:
    run: ../agents/python_createsequencegroups.cwl
    in:
      ref_dict: reference_dict
    out: [out_intervals]

  gatk_baserecalibrator:
    run: ../agents/gatk_baserecalibrator.cwl
    in:
      input_bam: picard_sortsam/output_sorted_bam
      knownsites: knownsites
      reference: indexed_reference_fasta
      sequence_interval: createsequencegrouping/out_intervals
    scatter: [sequence_interval]
    out: [output]

  gatk_gatherbqsrreports:
    run: ../agents/gatk_gatherbqsrreports.cwl
    in:
      input_brsq_reports: gatk_baserecalibrator/output
      output_basename: output_basename
    out: [output]

  gatk_applybqsr:
    run: ../agents/gatk_applybqsr.cwl
    in:
      reference: indexed_reference_fasta
      input_bam: picard_sortsam/output_sorted_bam
      bqsr_report: gatk_gatherbqsrreports/output
      sequence_interval: createsequencegrouping/out_intervals
    scatter: [sequence_interval]
    out: [recalibrated_bam]

  picard_gatherbamfiles:
    run: ../agents/picard_gatherbamfiles.cwl
    in:
      input_bam: gatk_applybqsr/recalibrated_bam
      output_bam_basename: output_basename
    out: [output]

  picard_collectaggregationmetrics:
    run: ../agents/picard_collectaggregationmetrics.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: indexed_reference_fasta
    out: [output]

  picard_collectreadgroupbamqualitymetrics:
    run: ../agents/picard_collectreadgroupbamqualitymetrics.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: indexed_reference_fasta
    out: [output]

  picard_collectwgsmetrics:
    run: ../agents/picard_collectwgsmetrics.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: indexed_reference_fasta
      intervals: wgs_coverage_interval_list
    out: [output]

  picard_calculatereadgroupchecksum:
    run: ../agents/picard_calculatereadgroupchecksum.cwl
    in:
      input_bam: picard_gatherbamfiles/output
    out: [output]

  samagents_coverttocram:
    run: ../agents/samagents_covert_to_cram.cwl
    in:
      input_bam: picard_gatherbamfiles/output
      reference: indexed_reference_fasta
    out: [output]

  picard_intervallistagents:
    run: ../agents/picard_intervallistagents.cwl
    in:
      interval_list: wgs_calling_interval_list
    out: [output]

  checkcontamination:
    run: ../agents/expression_checkcontamination.cwl
    in: 
      verifybamid_selfsm: verifybamid/output
    out: [contamination]

  gatk_haplotypecaller:
    run: ../agents/gatk_haplotypecaller.cwl
    in:
      reference: indexed_reference_fasta
      input_bam: picard_gatherbamfiles/output
      interval_list: picard_intervallistagents/output
      contamination: checkcontamination/contamination
    scatter: [interval_list]
    out: [output]

  picard_mergevcfs:
    run: ../agents/picard_mergevcfs.cwl
    in:
      input_vcf: gatk_haplotypecaller/output
      output_vcf_basename: output_basename
    out:
      [output]

  picard_collectgvcfcallingmetrics:
    run: ../agents/picard_collectgvcfcallingmetrics.cwl
    in:
      input_vcf: picard_mergevcfs/output
      reference_dict: reference_dict
      final_gvcf_base_name: output_basename
      dbsnp_vcf: dbsnp_vcf
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]

  gatk_validategvcf:
    run: ../agents/gatk_validategvcf.cwl
    in:
      input_vcf: picard_mergevcfs/output
      reference: indexed_reference_fasta
      wgs_calling_interval_list: wgs_calling_interval_list
      dbsnp_vcf: dbsnp_vcf
    out: []

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:AWSInstanceType'
    value: c5.9xlarge;ebs-gp2;768
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4
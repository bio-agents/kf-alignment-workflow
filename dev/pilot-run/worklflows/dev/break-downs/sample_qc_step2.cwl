cwlVersion: v1.0
class: Workflow
id: paired_sample_qc_step2
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
inputs:
  gather_input_bam: File
  indexed_reference_fasta: File
  intervals: File

outputs:
  collect_collect_aggregation_metrics:
    type: File[]
    outputSource: picard_collectaggregationmetrics/output1
  collect_collect_aggregation_pdf:
    type: File[]
    outputSource: picard_collectaggregationmetrics/output2
  picard_collect_wgs_metrics:
    type: File
    outputSource: picard_collectwgsmetrics/output
  picard_calculate_readgroup_checksum:
    type: File
    outputSource: picard_calculatereadgroupchecksum/output
  samagents_covert_to_cram:
    type: File
    outputSource: samagents_coverttocram/output
  picard_validate_sam_file:
    type: File
    outputSource: picard_validatesamfile/output
  collect_readgroupbam_quality_metrics:
    type: File[]
    outputSource: picard_collectreadgroupbamqualitymetrics/output1
  collect_readgroupbam_quality_pdf:
    type: File[]
    outputSource: picard_collectreadgroupbamqualitymetrics/output2

steps:
  picard_collectaggregationmetrics:
    run: ../agents/picard_collectaggregationmetrics.cwl
    in:
      input_bam: gather_input_bam
      reference: indexed_reference_fasta
    out: [output1, output2]
  picard_collectreadgroupbamqualitymetrics:
    run: ../agents/picard_collectreadgroupbamqualitymetrics.cwl
    in:
      input_bam: gather_input_bam
      reference: indexed_reference_fasta
    out: [output1, output2]
  picard_collectwgsmetrics:
    run: ../agents/picard_collectwgsmetrics.cwl
    in:
      input_bam: gather_input_bam
      reference: indexed_reference_fasta
      intervals: intervals
    out: [output]
  picard_calculatereadgroupchecksum:
    run: ../agents/picard_calculatereadgroupchecksum.cwl
    in:
      input_bam: gather_input_bam
    out: [output]
  samagents_coverttocram:
    run: ../agents/samagents_covert_to_cram.cwl
    in:
      input_bam: gather_input_bam
      reference: indexed_reference_fasta
    out: [output]
  picard_validatesamfile:
    run: ../agents/picard_validatesamfile.cwl
    in:
      input_bam: samagents_coverttocram/output
      reference: indexed_reference_fasta
    out: [output]

cwlVersion: v1.0
class: Workflow
id: kf_cram_to_gvcf
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  input_cram: File
  biospecimen_name: string
  output_basename: string
  indexed_reference_fasta: File
  dbsnp_vcf: File
  reference_dict: File
  contamination: float
  wgs_calling_interval_list: File
  wgs_evaluation_interval_list: File

outputs:
  gvcf_renamed: {type: File, outputSource: picard_renamesample/output}
  gvcf_calling_metrics: {type: 'File[]', outputSource: picard_collectgvcfcallingmetrics/output}

steps:
  picard_intervallistagents:
    run: ../agents/picard_intervallistagents.cwl
    in:
      interval_list: wgs_calling_interval_list
    out: [output]

  gatk_haplotypecaller:
    run: ../agents/gatk_haplotypecaller_cram.cwl
    in:
      contamination: contamination
      input_cram: input_cram
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

  picard_renamesample:
    run: ../agents/picard_renamesample.cwl
    in:
      gvcf: picard_mergevcfs/output
      biospecimen_name: biospecimen_name
    out:
      [output]

  picard_collectgvcfcallingmetrics:
    run: ../agents/picard_collectgvcfcallingmetrics.cwl
    in:
      dbsnp_vcf: dbsnp_vcf
      final_gvcf_base_name: output_basename
      input_vcf: picard_renamesample/output
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

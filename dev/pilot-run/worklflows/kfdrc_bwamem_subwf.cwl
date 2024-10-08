cwlVersion: v1.0
class: Workflow
id: bwa_mem_wf
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
inputs:
  input_reads: File
  indexed_reference_fasta: File
  base_name: string

outputs:
  aligned_bams:
    type: File[]
    outputSource: bwa_mem_split/output

steps:
  bwa_input_prepare:
    run: ../agents/bwa_input_prepare.cwl
    in:
      input_bam: input_reads
    out: [output, rg]

  expression_updatergsample:
    run: ../agents/expression_preparerg.cwl
    in:
      rg: bwa_input_prepare/rg
      sample: base_name
    out: [rg_str]

  bwa_mem_split:
    run: ../agents/bwa_mem_split.cwl
    in:
      ref: indexed_reference_fasta
      reads: bwa_input_prepare/output
      rg: bwa_input_prepare/rg
    scatter: [reads]
    out: [output]

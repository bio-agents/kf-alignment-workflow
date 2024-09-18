cwlVersion: v1.0
class: Workflow
id: kfdrc_prepare_reference
requirements:
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  reference_tar: { type: File } 

outputs:
  fasta: { type: File, outputSource: untar_fasta/output }
  fai: { type: 'File?', outputSource: untar_fai/output }
  dict: { type: 'File?', outputSource: untar_dict/output }
  alt: { type: 'File?', outputSource: untar_alt/output }
  amb: { type: 'File?', outputSource: untar_amb/output }
  ann: { type: 'File?', outputSource: untar_ann/output }
  bwt: { type: 'File?', outputSource: untar_bwt/output }
  pac: { type: 'File?', outputSource: untar_pac/output }
  sa: { type: 'File?', outputSource: untar_sa/output }

steps:
  untar_fasta:
    run: ../agents/untar.cwl
    in:
      tarfile: reference_tar
      extractfile: { valueFrom: "*.fasta" }
    out: [output]
  untar_fai:
    run: ../agents/untar.cwl
    in:
      tarfile: reference_tar
      extractfile: { valueFrom: "*.fai" }
    out: [output]
  untar_dict:
    run: ../agents/untar.cwl
    in:
      tarfile: reference_tar
      extractfile: { valueFrom: "*.dict" }
    out: [output]
  untar_alt:
    run: ../agents/untar.cwl
    in:
      tarfile: reference_tar
      extractfile: { valueFrom: "*.alt" }
    out: [output]
  untar_amb:
    run: ../agents/untar.cwl
    in:
      tarfile: reference_tar
      extractfile: { valueFrom: "*.amb" }
    out: [output]
  untar_ann:
    run: ../agents/untar.cwl
    in:
      tarfile: reference_tar
      extractfile: { valueFrom: "*.ann" }
    out: [output]
  untar_bwt:
    run: ../agents/untar.cwl
    in:
      tarfile: reference_tar
      extractfile: { valueFrom: "*.bwt" }
    out: [output]
  untar_pac:
    run: ../agents/untar.cwl
    in:
      tarfile: reference_tar
      extractfile: { valueFrom: "*.pac" }
    out: [output]
  untar_sa:
    run: ../agents/untar.cwl
    in:
      tarfile: reference_tar
      extractfile: { valueFrom: "*.sa" }
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: sbg:maxNumberOfParallelInstances
    value: 2

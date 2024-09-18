cwlVersion: v1.0
class: CommandLineAgent
id: samagents_bam_to_cram
doc: |-
  This agent converts the input BAM into a CRAM.
  The following programs are run in this agent:
    - samagents view
    - samagents index
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 4000
  - class: DockerRequirement
    dockerPull: 'kfdrc/samagents:1.8-dev'
baseCommand: [samagents, view]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      -C -T $(inputs.reference.path) -o $(inputs.input_bam.nameroot).cram $(inputs.input_bam.path)
      && samagents index $(inputs.input_bam.nameroot).cram
inputs:
  reference: {type: File, secondaryFiles: [.fai], doc: "Reference fasta with associated fai index"}
  input_bam: {type: File, secondaryFiles: [^.bai], doc: "Input bam file"}
outputs:
  output: { type: File, outputBinding: { glob: '*.cram' }, secondaryFiles: [.crai] }

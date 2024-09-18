cwlVersion: v1.0
class: CommandLineAgent
id: samagents_faidx
doc: |-
  This agent takes an input fasta and optionally a input index for the input fasta.
  If the index is not provided this agent will generate one.
  Finally the agent will return the input reference file with the index (generated or provided) as a secondaryFile.
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/samagents:1.9'
  - class: InitialWorkDirRequirement
    listing: [$(inputs.input_fasta),$(inputs.input_index)]
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
  - class: ShellCommandRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      $(inputs.input_index ? 'echo samagents faidx' : 'samagents faidx' )
inputs:
  input_fasta: { type: File, inputBinding: { position: 1 }, doc: "Input fasta file" }
  input_index: { type: 'File?', doc: "Input fasta index" }
outputs:
  fai: 
    type: File
    outputBinding:
      glob: "*.fai" 

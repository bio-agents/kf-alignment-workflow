cwlVersion: v1.0
class: CommandLineAgent
id: picard_createsequencedictionary
doc: |-
  This agent conditionally creats a sequence dictionary from an input fasta using Picard CreateSequenceDictionary.
  The agent will only generate the index if an the input_dict is not passed.
  The agent returnts the dict as its only output.
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.1.7.0R'
  - class: InitialWorkDirRequirement
    listing: [$(inputs.input_fasta),$(inputs.input_dict)]
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
  - class: ShellCommandRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      $(inputs.input_dict ? 'echo java -jar /gatk-package-4.1.7.0-local.jar' : 'java -jar /gatk-package-4.1.7.0-local.jar' )
  - position: 1
    shellQuote: false
    valueFrom: >-
      CreateSequenceDictionary
inputs:
  input_fasta:
    type: File
    inputBinding:
      position: 2
      prefix: "-R"
  input_dict:
    type: 'File?'
outputs:
  dict:
    type: File
    outputBinding:
      glob: "*.dict" 

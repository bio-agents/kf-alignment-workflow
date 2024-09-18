cwlVersion: v1.0
class: CommandLineAgent
id: tabix_index 
doc: >-
  This agent will run tabix conditionally dependent on whether an index is provided.
  The agent will output the input_file with the index, provided or created within, as a secondary file.
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/samagents:1.9'
  - class: InitialWorkDirRequirement
    listing: [$(inputs.input_file),$(inputs.input_index)]
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
  - class: ShellCommandRequirement

baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      $(inputs.input_index ? 'echo tabix -p vcf' : 'tabix -p vcf')

inputs:
  input_file: { type: 'File', doc: "Position sorted and compressed by bgzip input file", inputBinding: { position: 1, shellQuote: false } }
  input_index: { type: 'File?', doc: "Index file for the input_file, if one exists" }

outputs:
  output: 
    type: File
    outputBinding:
      glob: $(inputs.input_file.basename) 
    secondaryFiles: [.tbi]

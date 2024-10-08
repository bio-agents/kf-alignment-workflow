cwlVersion: v1.0
class: CommandLineAgent
id: samagents_cram2bam_w_index
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
      -b -T $(inputs.reference.path) -@ 35 $(inputs.input_cram.path) > $(inputs.output_basename).bam
      && samagents index -@ 35 $(inputs.output_basename).bam $(inputs.output_basename).bai
inputs:
  input_cram: File
  output_basename: string
  reference: {type: File, secondaryFiles: [.fai]}
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.bam'
    secondaryFiles: [^.bai]

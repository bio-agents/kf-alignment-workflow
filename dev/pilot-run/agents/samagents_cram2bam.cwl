cwlVersion: v1.0
class: CommandLineAgent
id: samagents_cram2bam
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'images.sbgenomics.com/bogdang/samagents:1.7-11-g041220d'
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      ${
          if (inputs.input_reads.nameext == '.cram')
           return "samagents view -b "
          else return "echo"
      }
inputs:
  input_reads:
    type: File
    inputBinding:
      position: 2
      shellQuote: false
  threads:
    type: int?
    inputBinding:
      position: 1
      prefix: '-@'
      shellQuote: false
  reference:
    type: File
    inputBinding:
      position: 1
      prefix: '--reference'
      shellQuote: false
outputs:
  bam_file:
    type: File
    outputBinding:
      glob: '*.bam'
      outputEval: |-
        ${
            if(inputs.input_reads.nameext == '.cram') return self
            else return inputs.input_reads
        }
stdout: $(inputs.input_reads.nameroot).bam

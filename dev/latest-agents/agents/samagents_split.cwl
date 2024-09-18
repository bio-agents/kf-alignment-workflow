class: CommandLineAgent
cwlVersion: v1.0
id: samagents_split
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/samagents:1.8-dev'
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      RG_NUM=`samagents view -H $(inputs.input_bam.path) | grep -c ^@RG`
      if [ $RG_NUM != 1 ]; then
        samagents split -f '%!.bam' -@ 36 --reference $(inputs.reference.path) $(inputs.input_bam.path)
      fi
inputs:
  input_bam: File
  reference: File
outputs:
  bam_files:
    type: File[]
    outputBinding:
      glob: '*.bam'
      outputEval: |-
        ${
          if (self.length == 0) return [inputs.input_bam]
          else return self
        }

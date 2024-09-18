class: CommandLineAgent
cwlVersion: v1.0
id: samagents_split
doc: |-
  This agent splits the input bam input read group bams if it has more than one readgroup.
  Programs run in this agent:
    - samagents view | grep
    - samagents split
  Using samagents view and grep count the header lines starting with @RG. If that number is
  not one, split the bam file into read group bams using samagents.
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/samagents:1.9'
  - class: InlineJavascriptRequirement
baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      set -eo pipefail
      RG_NUM=`samagents view -H $(inputs.input_bam.path) | grep -c ^@RG`
      if [ $RG_NUM != 1 ]; then
        samagents split -f '%!.bam' -@ 36 --reference $(inputs.reference.path) $(inputs.input_bam.path)
      fi
inputs:
  input_bam: { type: File, doc: "Input bam file" }
  reference: { type: File, doc: "Reference fasta file" }
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

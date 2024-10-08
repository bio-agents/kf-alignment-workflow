cwlVersion: v1.0
class: CommandLineAgent
id: picard_intervallistagents
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard:2.8.3'
baseCommand: [java, -Xmx2000m, -jar, /picard.jar]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      IntervalListAgents
      SCATTER_COUNT=50
      SUBDIVISION_MODE=BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW
      UNIQUE=true
      SORT=true
      BREAK_BANDS_AT_MULTIPLES_OF=1000000
      INPUT=$(inputs.interval_list.path)
      OUTPUT=$(runtime.outdir)
inputs:
  interval_list: File
outputs:
  output:
    type: File[]
    outputBinding:
      glob: 'temp*/*.interval_list'

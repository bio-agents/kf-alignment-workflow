cwlVersion: v1.0
class: CommandLineAgent
id: picard_qualityscoredistribution
doc: |-
  This agent plots the quality score distribution found in an input WGS/WXS bam.
  The following programs are run in this agent:
    - picard QualityScoreDistribution
  This agent is also made to be used conditionally with the conditional_run parameter.
  Simply pass an empty array to conditional_run and scatter on the input to skip.
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 12000
  - class: DockerRequirement
    dockerPull: 'kfdrc/picard-r:latest-dev'
baseCommand: [ java, -Xms5000m, -jar, /picard.jar, QualityScoreDistribution]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      INPUT=$(inputs.input_bam.path)
      REFERENCE_SEQUENCE=$(inputs.reference.path)
      OUTPUT=$(inputs.input_bam.nameroot).qual_score_dist.txt
      CHART_OUTPUT=$(inputs.input_bam.nameroot).qual_score_dist.pdf

inputs:
  input_bam: { type: File, secondaryFiles: [^.bai], doc: "Input bam file"}
  reference: { type: File, secondaryFiles: [.fai], doc: "Reference fasta with dict and fai indexes" }
  conditional_run: { type: int, doc: "Placeholder variable to allow conditional running" } 
outputs:
  metrics: { type: File, outputBinding: { glob: '*.qual_score_dist.txt' } }
  chart: { type: File, outputBinding: { glob: '*.qual_score_dist.pdf' } }

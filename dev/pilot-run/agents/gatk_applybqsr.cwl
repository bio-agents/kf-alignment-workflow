cwlVersion: v1.0
class: CommandLineAgent
id: gatk4_applybqsr
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.beta.1'
  - class: ResourceRequirement
    ramMin: 4500
baseCommand: [/gatk-launch, ApplyBQSR]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      --javaOptions "-Xms3000m
      -XX:+PrintFlagsFinal
      -XX:+PrintGCTimeStamps
      -XX:+PrintGCDateStamps
      -XX:+PrintGCDetails
      -Xloggc:gc_log.log
      -XX:GCTimeLimit=50
      -XX:GCHeapFreeLimit=10"
      --createOutputBamMD5
      --addOutputSAMProgramRecord
      -R $(inputs.reference.path)
      -I $(inputs.input_bam.path)
      --useOriginalQualities
      -O $(inputs.input_bam.nameroot).aligned.duplicates_marked.recalibrated.bam
      -bqsr $(inputs.bqsr_report.path)
      -SQQ 10 -SQQ 20 -SQQ 30
      -L $(inputs.sequence_interval.path)
inputs:
  reference: {type: File, secondaryFiles: [^.dict, .fai]}
  input_bam: {type: File, secondaryFiles: [^.bai]}
  bqsr_report: File
  sequence_interval: File
outputs:
  recalibrated_bam:
    type: File
    outputBinding:
      glob: '*bam'
    secondaryFiles: [^.bai, .md5]
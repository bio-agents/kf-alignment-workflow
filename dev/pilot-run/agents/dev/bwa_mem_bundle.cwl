cwlVersion: v1.0
class: CommandLineAgent
id: bwa_mem
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/bwa-picard:broad'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 5000
baseCommand: [java, -Xms5000m, -jar, /picard.jar]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      SamToFastq
      INPUT=$(inputs.input_bam.path)
      FASTQ=/dev/stdout
      INTERLEAVE=true
      NON_PF=true
      | bwa mem -K 100000000 -p -v 3 -t 16 -Y $(inputs.indexed_reference_fasta.path) - 
      | java -Dsamjdk.compression_level=2 -Xms4000m -jar /picard.jar
      MergeBamAlignment
      VALIDATION_STRINGENCY=SILENT
      EXPECTED_ORIENTATIONS=FR
      ATTRIBUTES_TO_RETAIN=X0
      ATTRIBUTES_TO_REMOVE=NM
      ATTRIBUTES_TO_REMOVE=MD
      ALIGNED_BAM=/dev/stdin
      UNMAPPED_BAM=$(inputs.input_bam.path)
      OUTPUT=$(inputs.input_bam.nameroot).aligned.unsorted.bam
      REFERENCE_SEQUENCE=$(inputs.indexed_reference_fasta.path)
      PAIRED_RUN=true
      SORT_ORDER='unsorted'
      IS_BISULFITE_SEQUENCE=false
      ALIGNED_READS_ONLY=false
      CLIP_ADAPTERS=false
      MAX_RECORDS_IN_RAM=2000000
      ADD_MATE_CIGAR=true
      MAX_INSERTIONS_OR_DELETIONS=-1
      PRIMARY_ALIGNMENT_STRATEGY=MostDistant
      PROGRAM_RECORD_ID='bwamem'
      PROGRAM_GROUP_NAME='bwamem'
      PROGRAM_GROUP_VERSION='0.7.15-r1140'
      PROGRAM_GROUP_COMMAND_LINE='bwa mem -K 100000000 -p -v 3 -t 16 -Y $(inputs.indexed_reference_fasta.basename)'
      ALIGNER_PROPER_PAIR_FLAGS=true UNMAP_CONTAMINANT_READS=true
      UNMAPPED_READ_STRATEGY=COPY_TO_TAG
inputs:
  input_bam:
    type: File
  indexed_reference_fasta:
    type: File
    secondaryFiles: [.64.amb, .64.ann, .64.bwt, .64.pac, .64.sa,
    ^.dict, .amb, .ann, .bwt, .pac, .sa]
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.bam'


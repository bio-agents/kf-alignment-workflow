cwlVersion: v1.0
class: CommandLineAgent
id: verifybamid_contamination
doc: |-
  This agent verifies whether the reads in particular file match previously known genotypes for an individual
  and checks whether the reads are contaminated as a mixture of two samples.
  The following programs are run in this agent:
    - VerifyBamID
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/verifybamid:1.0.2'
  - class: ResourceRequirement
    ramMin: 5000
    coresMin: 4
baseCommand: [/bin/VerifyBamID]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      --Verbose
      --NumPC 4
      --Output $(inputs.output_basename)
      --BamFile $(inputs.input_bam.path)
      --Reference $(inputs.ref_fasta.path)
      --UDPath $(inputs.contamination_sites_ud.path)
      --MeanPath $(inputs.contamination_sites_mu.path)
      --BedPath $(inputs.contamination_sites_bed.path)
      1>/dev/null
inputs:
  input_bam: { type: File, secondaryFiles: [^.bai], doc: "Input bam file" }
  ref_fasta: { type: File, secondaryFiles: [.fai], doc: "Reference fasta and fai index" }
  contamination_sites_ud: { type: File, doc: ".UD matrix file from SVD result of genotype matrix" }
  contamination_sites_mu: { type: File, doc: ".mu matrix file of genotype matrix" }
  contamination_sites_bed: { type: File, doc: ".Bed file for markers used in this analysis,format(chr\tpos-1\tpos\trefAllele\taltAllele)" }
  output_basename: { type: string, doc: "String to be used as the base filename for the output" }
outputs:
  output: { type: File, outputBinding: { glob: '*.selfSM' } }
  contamination:
    type: float
    outputBinding:
      glob: '*.selfSM'
      loadContents: true
      outputEval: |-
        ${
          var lines = self[0].contents.split('\n');
          for (var i = 1; i < lines.length; i++) {
            var fields = lines[i].split('\t');
            if (fields.length != 19) {
              continue;
            }
            return fields[6]/0.75;
          }
        }

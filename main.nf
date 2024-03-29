include { STAR_MAP_MERGE_SORT } from './workflows/star_map_merge_sort.nf'
include { ANALYSIS } from './workflows/analysis.nf' params(Utils.formatParamsForInclusion('analysisToRun', params.customAnalysisToRun))
include { REGISTER_LOW_READS } from  './modules/register_low_reads.nf'

workflow {

    if (params.help) {
        println(params.helpMessage)
        exit(0)
    }

    // Create Local Variables
    Integer lowReadsTreshold = params.lowReadsThreshold.toInteger()
    Boolean runStar = params.stepsToRun.contains("STAR")
    Boolean runAnalysis = params.stepsToRun.contains("Analysis")

    // Create data tuples
    ch_sampleInfo = Channel.value([params.sampleId, params.sampleDirectory, params.userId])
    ch_starReference = Channel.value([params.starDirectory,  params.referenceGenome, params.rsemReferencePrefix, params.gtfFile])
    ch_bigwigDirectory = Channel.value(params.sampleBigWigDirectory)

    // Versions channel
    ch_versions = Channel.empty()

    if (runStar) {
        // Fastqs channel
        ch_fastqs =
            Channel.fromList(params.fastqs)
                .map{ row ->
                    String fastq1Files = row.fastq1Files
                    String fastq2Files = row.fastq2Files
                    String readGroups = row.readGroups

                    return tuple(fastq1Files, fastq2Files, readGroups)
                }

        // Map/Merge using STAR
        STAR_MAP_MERGE_SORT(ch_fastqs, ch_starReference, ch_sampleInfo)
        ch_versions = ch_versions.mix(STAR_MAP_MERGE_SORT.out.versions)

        // Split into pass/fail channels
        ch_starOutput =
            STAR_MAP_MERGE_SORT.out.analysisTuple
                .branch {starBam, starBai, transcriptomeBam, junctionsTab, readCount ->
                    pass: readCount.toInteger() >= lowReadsTreshold
                    fail: readCount.toInteger() < lowReadsTreshold
                }

        // If not enough reads, write early exit message to stdout
        ch_lowReads = ch_starOutput.fail.map{starBam, starBai, transcriptomeBam, junctionsTab, readCount -> readCount}
        REGISTER_LOW_READS(ch_lowReads, ch_sampleInfo)

        // Define analysis input channels
        ch_analysisInput =
            ch_starOutput.pass
                .multiMap{starBam, starBai, transcriptomeBam, junctionsTab, readCount ->
                    starBam: [starBam, starBai]
                    transcriptomeBam: transcriptomeBam
                    junctionsTab: junctionsTab
                }
    }

    if (runAnalysis) {
        // StarBam Input channel
        ch_starBam = Channel.empty()
        if (runStar) {
            ch_starBam = ch_analysisInput.starBam
        }
        else if (anlparams.analysisStarBam) {
            ch_starBam =
                Channel.of(params.analysisStarBam)
                    .map{ analysisStarBam ->
                        Path starBam = file(analysisStarBam)
                        Path starBai = file(analysisStarBam + ".bai")

                        return tuple(starBam, starBai)
                    }
        }

        // TranscriptomBam Input channel
        ch_transcriptomeBam = Channel.empty()
        if (runStar) {
            ch_transcriptomeBam = ch_analysisInput.transcriptomeBam
        }
        else if (analysisToRun.contains("RSEM")) {
            ch_transcriptomeBam = Channel.of(params.analysisTranscriptomeBam)
        }

        // JunctionsTab Input channel
        ch_junctionsTab = Channel.empty()
        if (runStar) {
            ch_junctionsTab = ch_analysisInput.junctionsTab
        }
        else if (params.analysisSpliceJunctionsTab) {
            ch_junctionsTab = Channel.of(params.analysisSpliceJunctionsTab)
        }

        // Analysis
        ANALYSIS(ch_starBam, ch_transcriptomeBam, ch_junctionsTab, ch_starReference, ch_bigwigDirectory, ch_sampleInfo)
        ch_versions = ch_versions.mix(ANALYSIS.out.versions)
    }


    ch_versions.unique().collectFile(name: 'rna-star_software_versions.yaml', storeDir: "${params.sampleDirectory}")

}

include { STAR_MAP_MERGE_SORT } from './workflows/star_map_merge_sort.nf'
include { ANALYSIS } from './workflows/analysis.nf'
include { REGISTER_LOW_READS } from  './modules/register_low_reads.nf'

workflow {

    // Create params channels
    Integer lowReadsTreshold = params.lowReadsThreshold.toInteger()
    Boolean runStar = params.stepsToRun.contains("STAR")
    Boolean runAnalysis = params.stepsToRun.contains("Analysis")

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
        STAR_MAP_MERGE_SORT(ch_fastqs)
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
        REGISTER_LOW_READS(ch_lowReads)

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
        else if (params.analysisStarBam) {
            ch_starBam =
                Channel.of(params.analysisStarBam)
                    .map{ row ->
                        Path starBam = file(row.analysisStarBam)
                        Path starBai = file(row.analysisStarBam + ".bai")

                        return tuple(starBam, starBai)
                    }
        }

        // TranscriptomBam Input channel
        ch_transcriptomeBam = Channel.empty()
        if (runStar) {
            ch_transcriptomeBam = ch_analysisInput.transcriptomeBam
        }
        else if (params.analysisTranscriptomeBam) {
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
        ANALYSIS(ch_starBam, ch_transcriptomeBam, ch_junctionsTab)
        ch_versions = ch_versions.mix(ANALYSIS.out.versions)
    }


    ch_versions.unique().collectFile(name: 'rna-star_software_versions.yaml', storeDir: "${params.sampleDirectory}")

}

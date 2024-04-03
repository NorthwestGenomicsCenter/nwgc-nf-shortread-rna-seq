include { FASTX_QC} from './modules/fastx_quality_stats.nf'
include { STAR_MAP_MERGE_SORT } from './workflows/star_map_merge_sort.nf'
include { ANALYSIS } from './workflows/analysis.nf' params(Utils.formatParamsForInclusion('analysisToRun', params.customAnalysisToRun))
include { REGISTER_LOW_READS } from  './modules/register_low_reads.nf'

workflow {

    // Print help message --help entered at command line
    if (params.help) {
        println(params.helpMessage)
        exit(0)
    }

    // Verify the input paramters are well formed
    try {
        Utils.validateInputParams(params)
    }
    catch (Exception exception) {
        error "Undefined Input: " + exception.message
    }

    // Create Local Variables
    Boolean runFastXQC = params.stepsToRun.contains("FastxQC")
    Boolean runStar = params.stepsToRun.contains("STAR")
    Boolean runAnalysis = params.stepsToRun.contains("Analysis")

    // Create data tuples
    ch_sampleInfo = Channel.value([params.sampleId, params.sampleDirectory, params.userId])

    // Versions channel
    ch_versions = Channel.empty()

    if (runFastXQC) {

        // Fastqs channel
        ch_fastq1 = Channel.fromList(params.flowCellLaneLibraries).map{ flowCellLaneLibrary -> return flowCellLaneLibrary.fastq1}
        ch_fastq2 = Channel.fromList(params.flowCellLaneLibraries).map{ flowCellLaneLibrary -> return flowCellLaneLibrary.fastq2}
        ch_fastq = ch_fastq1.mix(ch_fastq2)

        ch_fastxQCDirectory = Channel.value(params.sampleDirectory + "/fastxQC")

        FASTX_QC(ch_fastq, ch_fastxQCDirectory, ch_sampleInfo)
    }

    if (runStar) {
        Integer lowReadsTreshold = params.lowReadsThreshold.toInteger()
        ch_starReference = Channel.value([params.starDirectory,  params.referenceGenome, params.rsemReferencePrefix, params.gtfFile])

        // Format star input
        String fastq1Input = ""
        String fastq2Input = ""
        String readGroupInput = ""
        try {
            fastq1Input = Utils.formatFastq1InputForStar(params.flowCellLaneLibraries)
            fastq2Input = Utils.formatFastq2InputForStar(params.flowCellLaneLibraries)
            readGroupInput = Utils.formatReadGroupInputForStar(params.sequencingCenter, params.sequencingPlatform, params.sampleId, params.flowCellLaneLibraries)
        }
        catch (Exception exception) {
            error exception.message
        }
        ch_starInput = Channel.value([fastq1Input, fastq2Input, readGroupInput])

        // Map/Merge using STAR
        STAR_MAP_MERGE_SORT(ch_starInput, ch_starReference, ch_sampleInfo)
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
        ch_bigwigDirectory = Channel.value(params.sampleDirectory + "/tracks")
        ch_sampleQCDirectory = Channel.value(params.sampleDirectory + "/qc")
        
        // StarBam Input channel
        ch_starBam = Channel.empty()
        if (runStar) {
            ch_starBam = ch_analysisInput.starBam
        }
        else {
            ch_starBam =
                Channel.of(params.analysisStarBam)
                    .map{ analysisStarBam ->
                        starBam = analysisStarBam
                        starBai = analysisStarBam + ".bai"

                        return tuple(starBam, starBai)
                    }
        }

        // TranscriptomBam Input channel
        ch_transcriptomeBam = Channel.empty()
        if (runStar) {
            ch_transcriptomeBam = ch_analysisInput.transcriptomeBam
        }
        else {
            ch_transcriptomeBam = Channel.of(params.analysisTranscriptomeBam)
        }

        // JunctionsTab Input channel
        ch_junctionsTab = Channel.empty()
        if (runStar) {
            ch_junctionsTab = ch_analysisInput.junctionsTab
        }
        else {
            ch_junctionsTab = Channel.of(params.analysisSpliceJunctionsTab)
        }

        // Analysis
        ANALYSIS(ch_starBam, ch_transcriptomeBam, ch_junctionsTab, ch_starReference, ch_bigwigDirectory, ch_sampleQCDirectory, ch_sampleInfo)
        ch_versions = ch_versions.mix(ANALYSIS.out.versions)
    }


    ch_versions.unique().collectFile(name: 'rna-star_software_versions.yaml', storeDir: "${params.sampleDirectory}")

}

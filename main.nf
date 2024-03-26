include { STAR_MAP_MERGE_SORT } from './workflows/star_map_merge_sort.nf'
include { ANALYSIS } from './workflows/analysis.nf'

workflow {

    // Versions channel
    ch_versions = Channel.empty()
    ch_analysisInput = Channel.empty()

    // Map/Merge using STAR
    ch_fastqs = Channel.fromList(params.fastqs)
    STAR_MAP_MERGE_SORT(ch_fastqs)
    ch_versions = ch_versions.mix(STAR_MAP_MERGE_SORT.out.versions)

    read_count_ch = STAR_MAP_MERGE_SORT.out.analysisTuple
      .branch {starBam, starBai, transcriptomeBam, junctionsTab, readCount ->
            pass: readCount.isInteger() && readCount.toInteger() >= 1000
            fail: !readCount.isInteger() || readCount.toInteger() < 1000
      }

    // If not enough reads, write early exit message to stdout
    read_count_ch.fail.view()

    // Analysis
    ch_analysisInput = read_count_ch.pass.ifEmpty(Channel.fromList(params.analysis))

    // Enough reads, so proceed with RNA Analysis
    ANALYSIS(ch_analysisInput)
    ch_versions = ch_versions.mix(ANALYSIS.out.versions)

    ch_versions.unique().collectFile(name: 'rna-star_software_versions.yaml', storeDir: "${params.sampleDirectory}")

}

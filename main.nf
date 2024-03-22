include { STAR_MAP_MERGE_SORT } from './workflows/star_map_merge_sort.nf'
include { ANALYSIS } from './workflows/analysis.nf'

workflow {

    // Versions channel
    ch_versions = Channel.empty()
    ch_analysisInput = Channel.empty()

    // Map/Merge using STAR
    ch_fastqs = Channel.fromList(param.fastqs)
    STAR_MAP_MERGE_SORT(ch_fastqs)
    ch_versions = ch_versions.mix(STAR_MAP_MERGE_SORT.out.versions)

    read_count_ch = STAR_MAP_MERGE_SORT.out.readCount
      .branch {readCount ->
            pass: readCount.isInteger() && readCount.toInteger() >= 1000
                  return STAR_MAP_MERGE_SORT.out
            fail: !readCount.isInteger() || readCount.toInteger() < 1000
                  return "Not enough reads to proceed " + readCount
      }

    // If not enough reads, write early exit message to stdout
    read_count_ch.fail.view()
    ch_analysisInput.mix(read_count_ch.pass)

    // Check for workflow starting from merge

    // Enough reads, so proceed with RNA Analysis
    ANALYSIS(ch_analysisInput.collect())
    ch_versions = ch_versions.mix(ANALYSIS.out.versions)

    ch_versions.unique().collectFile(name: 'rna-star_software_versions.yaml', storeDir: "${params.sampleDirectory}")

}

import groovy.json.JsonSlurper

include { STAR_MAP_MERGE_SORT } from './workflows/star_map_merge_sort.nf'
include { RNA_ANALYSIS } from './workflows/rna_analysis.nf'

workflow {

    // Versions channel
    ch_versions = Channel.empty()

    // Map/Merge using STAR
    println "Starting STAR_MAP_MERGE_SORT"
    STAR_MAP_MERGE_SORT()
    ch_versions = ch_versions.mix(STAR_MAP_MERGE_SORT.out.versions)

    // read_count_ch = STAR_MAP_MERGE_SORT.out.readCount
    //                     .branch {readCount ->
    //                        pass: readCount.isInteger() && readCount.toInteger() >= 1000
    //                              return STAR_MAP_MERGE_SORT.out
    //                        fail: !readCount.isInteger() || readCount.toInteger() < 1000
    //                              return "Not enough reads to proceed " + readCount
    //                    }

    read_count_ch = STAR_MAP_MERGE_SORT.out
                        .branch {mergeSortOut ->
                           def readCount = mergeSortOut.readCount
                           pass: readCount.isInteger() && readCount.toInteger() >= 1000
                                 return mergeSortOut
                           fail: !readCount.isInteger() || readCount.toInteger() < 1000
                                 return "Not enough reads to proceed " + readCount
                       }

    // If not enough reads, write early exit message to stdout
    read_count_ch.fail.view()
    read_count_ch.pass.view{ "$it is pass"}

    // Enough reads, so proceed with RNA Analysis
    RNA_ANALYSIS(read_count_ch.pass)

    ch_versions.unique().collectFile(name: 'rna_star_software_versions.yaml', storeDir: "${params.sampleDirectory}")

}

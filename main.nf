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

    read_count_ch = STAR_MAP_MERGE_SORT.out.readCountJson
                       .map{ jsonFile ->
                           def jsonObj = new JsonSlurper().parseText(jsonFile.text)
                           return [ jsonObj.read_count ]
                       }
                       .branch {readCount ->
                           pass: readCount[0] >= 1000
                                 return readCount
                           fail: readCount[0] < 1000
                                 return "Not enough reads to proceed " + readCount
                       }

    read_count_ch.fail.view{ "$it is fail" }

    RNA_ANALYSIS(read_count_ch.pass, STAR_MAP_MERGE_SORT.out.transcriptome_bam)

    ch_versions.unique().collectFile(name: 'rna_star_software_versions.yaml', storeDir: "${params.sampleDirectory}")

}

include { STAR_MAP_MERGE_SORT } from './workflows/star_map_merge_sort.nf'

workflow {

    // Map/Merge using STAR
    STAR_MAP_MERGE_SORT()
    ch_versions = ch_versions.mix(STAR_MAP_MERGE_SORT.out.versions)

    if (!STAR_MAP_MERGE_SORT.out.readCountsPassed) {
        error "Error:  Not enough reads to proceed: " + STAR_MAP_MERGE_SORT.out.readCount
    }

    ch_versions.unique().collectFile(name: 'rna_star_software_versions.yaml', storeDir: "${params.sampleDirectory}")

}

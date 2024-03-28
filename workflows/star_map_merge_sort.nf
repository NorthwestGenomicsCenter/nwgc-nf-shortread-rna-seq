include { STAR } from '../modules/star/star.nf'
include { SAMBAMBA_SORT } from '../modules/star/sambamba_sort.nf'
include { CHECK_MAPPED_READ_COUNT } from '../modules/star/check_mapped_read_count.nf'

workflow STAR_MAP_MERGE_SORT {

    take:
        fastqsTuple
        starDirectory
        userInfoTuple

    main:

        STAR(fastqsTuple, starDirectory, userInfoTuple)
        SAMBAMBA_SORT(STAR.out.aligned_bam, userInfoTuple)
        CHECK_MAPPED_READ_COUNT(SAMBAMBA_SORT.out.sortedBamTuple, userInfoTuple)

        // Versions
        ch_versions = Channel.empty()
        ch_versions = ch_versions.mix(STAR.out.versions)
        ch_versions = ch_versions.mix(SAMBAMBA_SORT.out.versions)

    emit:
        analysisTuple = SAMBAMBA_SORT.out.sortedBamTuple.merge(STAR.out.transcriptome_bam).merge(STAR.out.spliceJunctions_tab).merge(CHECK_MAPPED_READ_COUNT.out.readCount)
        readsPerGene_tab = STAR.out.readsPerGene_tab
        versions = ch_versions
}

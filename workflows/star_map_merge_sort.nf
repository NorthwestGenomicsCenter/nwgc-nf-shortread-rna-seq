include { STAR } from '../modules/star/star.nf'
include { SAMBAMBA_SORT } from '../modules/star/sambamba_sort.nf'
include { CHECK_MAPPED_READ_COUNT } from '../modules/star/check_mapped_read_count.nf'

workflow STAR_MAP_MERGE_SORT {

    take:
        fastqsTuple

    main:

        STAR(fastqsTuple)
        SAMBAMBA_SORT(STAR.out.aligned_bam)
        CHECK_MAPPED_READ_COUNT(SAMBAMBA_SORT.out.sortedByCoordinate_bam, SAMBAMBA_SORT.out.sortedByCoordinate_bai)

        // Versions
        ch_versions = Channel.empty()
        ch_versions = ch_versions.mix(STAR.out.versions)
        ch_versions = ch_versions.mix(SAMBAMBA_SORT.out.versions)

    emit:
        starTuple = SAMBAMBA_SORT.out.sortedByCoordinate_bam.merge(SAMBAMBA_SORT.out.sortedByCoordinate_bai).merge(CHECK_MAPPED_READ_COUNT.out.readCount)
        transcriptomeTuple = STAR.out.transcriptome_bam.merge(CHECK_MAPPED_READ_COUNT.out.readCount)
        junctionsTuple = STAR.out.spliceJunctions_tab.merge(CHECK_MAPPED_READ_COUNT.out.readCount)
        readCount = CHECK_MAPPED_READ_COUNT.out.readCount
        readsPerGene_tab = STAR.out.readsPerGene_tab
        versions = ch_versions
}

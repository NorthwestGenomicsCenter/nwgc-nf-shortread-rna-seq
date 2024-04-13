include { STAR } from '../modules/star/star.nf'
include { SAMBAMBA_SORT } from '../modules/star/sambamba_sort.nf'
include { PICARD_MARK_DUPLICATES } from '../modules/star/picard_mark_duplicates.nf'
include { CHECK_MAPPED_READ_COUNT } from '../modules/star/check_mapped_read_count.nf'

workflow STAR_MAP_MERGE_SORT {

    take:
        fastqsTuple
        starReferenceTuple
        sampleInfoTuple

    main:

        STAR(fastqsTuple, starReferenceTuple, sampleInfoTuple)
        SAMBAMBA_SORT(STAR.out.aligned_bam, sampleInfoTuple)
        PICARD_MARK_DUPLICATES(SAMBAMBA_SORT.out.sortedBamTuple, sampleInfoTuple)
        CHECK_MAPPED_READ_COUNT(PICARD_MARK_DUPLICATES.out.bamTuple, sampleInfoTuple)

        // Versions
        ch_versions = Channel.empty()
        ch_versions = ch_versions.mix(STAR.out.versions)
        ch_versions = ch_versions.mix(SAMBAMBA_SORT.out.versions)
        ch_versions = ch_versions.mix(PICARD_MARK_DUPLICATES.out.versions)
 
    emit:
        analysisTuple = PICARD_MARK_DUPLICATES.out.bamTuple.merge(STAR.out.transcriptome_bam).merge(STAR.out.spliceJunctions_tab).merge(CHECK_MAPPED_READ_COUNT.out.readCount)
        readsPerGene_tab = STAR.out.readsPerGene_tab
        versions = ch_versions
}

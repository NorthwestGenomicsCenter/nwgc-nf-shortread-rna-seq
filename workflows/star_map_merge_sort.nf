include { STAR } from '../modules/star.nf'
include { SAMBAMBA_SORT } from '../modules/sambamba_sort.nf'
include { CHECK_MAPPED_READ_COUNT } from '../modules/check_mapped_read_count.nf'

workflow STAR_MAP_MERGE_SORT {

    main:
        STAR(params.fastq1Files, params.fastqs2Files, params.readGroups)
        SAMBAMBA_SORT(STAR.out.aligned_bam)
        tuple val(readCount), val(readCountsPassed) = CHECK_MAPPED_READ_COUNT(SAMBAMBA_SORT.out.sortedByCoordinate_bam)

        // Versions
        ch_versions = Channel.empty()
        ch_versions = ch_versions.mix(STAR.out.versions)
        ch_versions = ch_versions.mix(SAMBAMBA_SORT.out.versions)

    emit:
        transcriptome_bam = STAR.out.transcriptome_bam
        sortedByCoordinate_bam = SAMBAMBA_SORT.out.sortedByCoordinate_bam
        spliceJunctions_tab = STAR.out.spliceJunctions_tab
        readsPerGene_tab = STAR.out.readsPerGene_tab
        readCount = readCount
        readCountsPassed = readCountsPassed
        versions = ch_versions
}
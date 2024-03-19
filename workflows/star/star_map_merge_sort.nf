include { STAR } from '../../modules/star/star.nf'
include { SAMBAMBA_SORT } from '../../modules/star/sambamba_sort.nf'
include { CHECK_MAPPED_READ_COUNT } from '../../modules/star/check_mapped_read_count.nf'

workflow STAR_MAP_MERGE_SORT {

    main:

        fastqInfo_ch = Channel.of(params.fastqs).map(row -> {
            def fastq1Files = row.fastq1Files
            def fastq2Files = row.fastq2Files
            def readGroups = row.readGroups
            return tuple (fastq1Files, fastq1Files, readGroups)
            })

        STAR(fastqInfo_ch)
        SAMBAMBA_SORT(STAR.out.aligned_bam)
        CHECK_MAPPED_READ_COUNT(SAMBAMBA_SORT.out.sortedByCoordinate_bam, SAMBAMBA_SORT.out.sortedByCoordinate_bai)

        // Versions
        ch_versions = Channel.empty()
        ch_versions = ch_versions.mix(STAR.out.versions)
        ch_versions = ch_versions.mix(SAMBAMBA_SORT.out.versions)

    emit:
        transcriptome_bam = STAR.out.transcriptome_bam
        sortedByCoordinate_bam = SAMBAMBA_SORT.out.sortedByCoordinate_bam
        sortedByCoordinate_bai = SAMBAMBA_SORT.out.sortedByCoordinate_bai
        spliceJunctions_tab = STAR.out.spliceJunctions_tab
        readsPerGene_tab = STAR.out.readsPerGene_tab
        readCount = CHECK_MAPPED_READ_COUNT.out.readCount
        versions = ch_versions
}

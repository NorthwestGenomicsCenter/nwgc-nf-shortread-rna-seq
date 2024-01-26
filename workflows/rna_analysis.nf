include { RSEM } from '../modules/rsem.nf'
include { JUNCTIONS_BED } from '../modules/junctions_bed.nf'
include { PICARD_MARK_DUPS } from '../modules/picard_mark_dups.nf'
include { PICARD_INSERT_SIZE } from '../modules/picard_insert_size.nf'

workflow RNA_ANALYSIS {

    take:
        starOut

    main:

        RSEM(starOut.transcriptome_bam.get())
        JUNCTIONS_BED(starOut.spliceJunctions_tab.get())

        PICARD_MARK_DUPS(starOut.sortedByCoordinate_bam.get(), starOut.sortedByCoordinate_bai.get())

        // VCF

        // QC
        PICARD_INSERT_SIZE(PICARD_MARK_DUPS.out.bam, PICARD_MARK_DUPS.out.bai)

        // BigWig


        // Versions
        ch_versions = Channel.empty()
        ch_versions = ch_versions.mix(RSEM.out.versions)
        ch_versions = ch_versions.mix(JUNCTIONS_BED.out.versions)
        ch_versions = ch_versions.mix(PICARD_MARK_DUPS.out.versions)
        ch_versions = ch_versions.mix(PICARD_INSERT_SIZE.out.versions)

    emit:
        versions = ch_versions

}

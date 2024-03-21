include { RSEM } from '../../modules/analysis/rsem.nf'
include { JUNCTIONS_BED } from '../../modules/analysis/junctions_bed.nf'
include { PICARD_MARK_DUPLICATES } from '../../modules/analysis/picard_mark_duplicates.nf'
include { BIGWIG } from './bigwig.nf'
include { CALL_VARIANTS } from './call_variants.nf'
include { QC } from './qc.nf'

workflow ANALYSIS {

    take:
        starOut

    main:

        RSEM(starOut.transcriptome_bam.get())
        JUNCTIONS_BED(starOut.spliceJunctions_tab.get())
        PICARD_MARK_DUPLICATES(starOut.sortedByCoordinate_bam.get(), starOut.sortedByCoordinate_bai.get())
        CALL_VARIANTS(PICARD_MARK_DUPLICATES.out.bam, PICARD_MARK_DUPLICATES.out.bai)
        QC(PICARD_MARK_DUPLICATES.out.bam, PICARD_MARK_DUPLICATES.out.bai)
        BIGWIG(PICARD_MARK_DUPLICATES.out.bam, PICARD_MARK_DUPLICATES.out.bai)

        ch_versions = Channel.empty()
        ch_versions = ch_versions.mix(RSEM.out.versions)
        ch_versions = ch_versions.mix(JUNCTIONS_BED.out.versions)
        ch_versions = ch_versions.mix(PICARD_MARK_DUPLICATES.out.versions)
        ch_versions = ch_versions.mix(CALL_VARIANTS.out.versions)
        ch_versions = ch_versions.mix(QC.out.versions)
        ch_versions = ch_versions.mix(BIGWIG.out.versions)

    emit:
        versions = ch_versions

}

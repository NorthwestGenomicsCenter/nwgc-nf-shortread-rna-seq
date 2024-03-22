include { RSEM } from '../modules/analysis/rsem.nf'
include { JUNCTIONS_BED } from '../modules/analysis/junctions_bed.nf'
include { PICARD_MARK_DUPLICATES } from '../modules/analysis/picard_mark_duplicates.nf'
include { BIGWIG } from './analysis/bigwig.nf'
include { CALL_VARIANTS } from './analysis/call_variants.nf'
include { QC } from './analysis/qc.nf'

workflow ANALYSIS {

    take:
        analysisInputTuple 

    main:

        RSEM(analysisInputTuple)
        JUNCTIONS_BED(analysisInputTuple)
        PICARD_MARK_DUPLICATES(analysisInputTuple)
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

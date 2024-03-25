include { PICARD_INSERT_SIZE } from '../../modules/analysis/qc/qc_picard_insert_size.nf'
include { RNASEQC } from '../../modules/analysis/qc/qc_rnaseqc.nf'

workflow QC {

    take:
        markedDupsBamTuple

    main:

        PICARD_INSERT_SIZE(markedDupsBamTuple)
        RNASEQC(markedDupsBamTuple)

        // Versions
        ch_versions = Channel.empty()
        ch_versions = ch_versions.mix(PICARD_INSERT_SIZE.out.versions)
        ch_versions = ch_versions.mix(RNASEQC.out.versions)

    emit:
        versions = ch_versions

}

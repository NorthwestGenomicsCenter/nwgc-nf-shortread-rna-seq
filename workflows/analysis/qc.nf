include { PICARD_INSERT_SIZE } from '../../modules/analysis/qc/picard_insert_size.nf'
include { RNASEQC } from '../../modules/analysis/qc/rnaseqc.nf'

workflow QC {

    take:
        markedDupsBamTuple
        starReferenceTuple
        sampleQCDirectory
        sampleInfoTuple

    main:

        PICARD_INSERT_SIZE(markedDupsBamTuple, sampleQCDirectory, sampleInfoTuple)
        RNASEQC(markedDupsBamTuple, starReferenceTuple, sampleQCDirectory, sampleInfoTuple)

        // Versions
        ch_versions = Channel.empty()
        ch_versions = ch_versions.mix(PICARD_INSERT_SIZE.out.versions)
        ch_versions = ch_versions.mix(RNASEQC.out.versions)

    emit:
        versions = ch_versions

}

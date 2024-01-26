include { RSEM } from '../modules/rsem.nf'
include { JUNCTIONS_BED } from '../modules/junctions_bed.nf'

workflow RNA_ANALYSIS {

    take:
        starOut

    main:

        RSEM(starOut.transcriptome_bam.get())
        JUNCTIONS_BED(starOut.spliceJunctions_tab.get())

        // Versions
        ch_versions = Channel.empty()
        ch_versions = ch_versions.mix(RSEM.out.versions)
        ch_versions = ch_versions.mix(JUNCTIONS_BED.out.versions)

    emit:
        versions = ch_versions

}

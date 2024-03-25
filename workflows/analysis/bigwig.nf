include { DEEPTOOLS_BAM_COVERAGE } from '../../modules/analysis/deeptools_bam_coverage.nf'

workflow BIGWIG {

    take:
        markedDupsBamTuple

    main:

        // Chromsomee-Strand Input for DEEPTOOLS_BAM_COVERAGE
        chromosomesChannel = Channel.fromList(params.chromosomes)
        strandChannel = Channel.fromList(['forward','reverse'])
        chromosomeStrandTuple = chromosomesChannel.combine(strandChannel)
        deeptoolsInputTuple = chromosomeStrandTuple.combine(markeDupsBamTuple) 

        DEEPTOOLS_BAM_COVERAGE(deeptoolsInputTuple)

        // Versions
        ch_versions = Channel.empty()
        ch_versions = ch_versions.mix(DEEPTOOLS_BAM_COVERAGE.out.versions)

    emit:
        versions = ch_versions

}

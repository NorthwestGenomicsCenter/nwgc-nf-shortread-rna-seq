include { DEEPTOOLS_BAM_COVERAGE } from '../../modules/analysis/deeptools_bam_coverage.nf'

workflow BIGWIG {

    take:
        markedDupsBam
        markedDupsBai

    main:

        // Chromsomee-Strand Input for DEEPTOOLS_BAM_COVERAGE
        chromosomesChannel = Channel.fromList(params.chromosomes)
        strandChannel = Channel.fromList('forward','reverse')
        chromosomeStrandTuple = chromosomesChannel.combine(strandChannel)

        DEEPTOOLS_BAM_COVERAGE(chromosomeStrandTuple, markedDupsBam, markedDupsBai)

        // Versions
        ch_versions = Channel.empty()
        ch_versions = ch_versions.mix(DEEPTOOLS_BAM_COVERAGE.out.versions)

    emit:
        versions = ch_versions

}

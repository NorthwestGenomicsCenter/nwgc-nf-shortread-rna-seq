params.analysisToRun = ["RSEM", "Junctions", "VCF", "QC", "BigWig"]
include { RSEM } from '../modules/analysis/rsem.nf'
include { JUNCTIONS_BED } from '../modules/analysis/junctions_bed.nf'
include { BIGWIG } from './analysis/bigwig.nf'
include { CALL_VARIANTS } from './analysis/call_variants.nf'
include { QC } from './analysis/qc.nf'

workflow ANALYSIS {

    take:
        starBamTuple
        transcriptomeBam
        junctionsTab
        starReferenceTuple
        bigWigDirectory
        sampleQCDirectory
        sampleInfoTuple
        organism
        effectiveGenomeSize

    main:

        ch_versions = Channel.empty()

        if (params.analysisToRun.contains("RSEM")) {
            RSEM(transcriptomeBam, starReferenceTuple, sampleInfoTuple)
            ch_versions = ch_versions.mix(RSEM.out.versions)
        }

        if (params.analysisToRun.contains("Junctions")) {
            JUNCTIONS_BED(junctionsTab, sampleInfoTuple)
            ch_versions = ch_versions.mix(JUNCTIONS_BED.out.versions)
        }

        if (params.analysisToRun.contains("VCF")) {
            CALL_VARIANTS(starBamTuple, starReferenceTuple, sampleInfoTuple)
            ch_versions = ch_versions.mix(CALL_VARIANTS.out.versions)
        }

        if (params.analysisToRun.contains("QC")) {
            QC(starBamTuple, starReferenceTuple, sampleQCDirectory, sampleInfoTuple)
            ch_versions = ch_versions.mix(QC.out.versions)
        }

        if (params.analysisToRun.contains("BigWig")) {
            BIGWIG(starBamTuple, bigWigDirectory, sampleInfoTuple, organism, effectiveGenomeSize)
            ch_versions = ch_versions.mix(BIGWIG.out.versions)
        }

    emit:
        versions = ch_versions

}

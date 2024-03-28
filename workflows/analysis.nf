include { RSEM } from '../modules/analysis/rsem.nf'
include { JUNCTIONS_BED } from '../modules/analysis/junctions_bed.nf'
include { PICARD_MARK_DUPLICATES } from '../modules/analysis/picard_mark_duplicates.nf'
include { BIGWIG } from './analysis/bigwig.nf'
include { CALL_VARIANTS } from './analysis/call_variants.nf'
include { QC } from './analysis/qc.nf'

workflow ANALYSIS {

    take:
        starBamTuple
        transcriptomeBam
        junctionsTab 

    main:

        ch_versions = Channel.empty()

        if (params.analysisToRun.contains("RSEM")) {
            RSEM(transcriptomeBam)
            ch_versions = ch_versions.mix(RSEM.out.versions)
        }

        if (params.analysisToRun.contains("Junctions")) {
            JUNCTIONS_BED(junctionsTab)
            ch_versions = ch_versions.mix(JUNCTIONS_BED.out.versions)
        }

        if (params.analysisToRun.contains("VCF") || params.analysisToRun.contains("QC") || params.analysisToRun.contains("BigWig")) {
            PICARD_MARK_DUPLICATES(starBamTuple)
            ch_versions = ch_versions.mix(PICARD_MARK_DUPLICATES.out.versions)

            if (params.analysisToRun.contains("VCF")) {
                CALL_VARIANTS(PICARD_MARK_DUPLICATES.out.bamTuple)
                ch_versions = ch_versions.mix(CALL_VARIANTS.out.versions)
            }

            if (params.analysisToRun.contains("QC")) {
                QC(PICARD_MARK_DUPLICATES.out.bamTuple)
                ch_versions = ch_versions.mix(QC.out.versions)
            }

            if (params.analysisToRun.contains("BigWig")) {
                BIGWIG(PICARD_MARK_DUPLICATES.out.bamTuple)
                ch_versions = ch_versions.mix(BIGWIG.out.versions)
            }
        }


    emit:
        versions = ch_versions

}

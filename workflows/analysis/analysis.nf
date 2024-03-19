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

        ch_versions = Channel.empty()
        def runAll = params.analysisToRun.contains("All")

        // Analysis that use non-bam output from STAR
        if (runAll || analysisToRun.contains("RSEM")) {
            RSEM(starOut.transcriptome_bam.get())
            ch_versions = ch_versions.mix(RSEM.out.versions)
        }
        if (runAll || analysisToRun.contains("Junctions")) {
            JUNCTIONS_BED(starOut.spliceJunctions_tab.get())
        ch_versions = ch_versions.mix(JUNCTIONS_BED.out.versions)
        }

        // Analysis that use sorted bam output from star
        if (runAll || analysisToRun.contains("VCF") || analysisToRun.contains("QC") || analysisToRun.contains("BigWig") ) {
            PICARD_MARK_DUPLICATES(starOut.sortedByCoordinate_bam.get(), starOut.sortedByCoordinate_bai.get())
            ch_versions = ch_versions.mix(PICARD_MARK_DUPLICATES.out.versions)
        }
        if (runAll || analysisToRun.contains("VCF")) {
            CALL_VARIANTS(PICARD_MARK_DUPLICATES.out.bam, PICARD_MARK_DUPLICATES.out.bai)
            ch_versions = ch_versions.mix(CALL_VARIANTS.out.versions)
        }
        if (runAll || analysisToRun.contains("QC")) {
            QC(PICARD_MARK_DUPLICATES.out.bam, PICARD_MARK_DUPLICATES.out.bai)
            ch_versions = ch_versions.mix(QC.out.versions)
        }
        if (runAll || analysisToRun.contains("BigWig")) {
            BIGWIG(PICARD_MARK_DUPLICATES.out.bam, PICARD_MARK_DUPLICATES.out.bai)
           ch_versions = ch_versions.mix(BIGWIG.out.versions)
        }
 
    emit:
        versions = ch_versions

}

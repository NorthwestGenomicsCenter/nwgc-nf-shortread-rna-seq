include { RSEM } from '../modules/rsem.nf'

workflow RNA_ANALYSIS {

    take:
        readCount
        transcriptome_bam

    main:

        println "Starting RNA_ANALYSIS"
        RSEM(readCount, transcriptome_bam)
        println "Finshed RNA_ANALYSIS"

}

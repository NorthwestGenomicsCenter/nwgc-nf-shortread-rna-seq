include { RSEM } from '../modules/rsem.nf'

workflow RNA_ANALYSIS {

    take:
        starOutput

    main:

        println "Starting RNA_ANALYSIS"
        RSEM(starOutput.transcriptome_bam.value())
        println "Finshed RNA_ANALYSIS"

}

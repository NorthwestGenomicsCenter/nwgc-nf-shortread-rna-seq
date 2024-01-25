include { RSEM } from '../modules/rsem.nf'

workflow RNA_ANALYSIS {

    take:
        mergeSortOut

    main:

        println "Starting RNA_ANALYSIS"
        RSEM(mergeSortOut.transcriptome_bam.get())
        println "Finshed RNA_ANALYSIS"

}

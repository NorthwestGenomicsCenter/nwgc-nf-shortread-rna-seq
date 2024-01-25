include { RSEM } from '../modules/rsem.nf'

workflow RNA_ANALYSIS {

    take:
        mergeSort

    main:

        println "Starting RNA_ANALYSIS"
        RSEM(mergeSort.out.transcriptome_bam.get())
        println "Finshed RNA_ANALYSIS"

}

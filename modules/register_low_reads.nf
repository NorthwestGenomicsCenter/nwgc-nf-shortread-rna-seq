process REGISTER_LOW_READS {

    label "REGISTER_LOW_READS_${params.sampleId}_${params.userId}"

    publishDir "$params.sampleDirectory", mode:  'link', pattern: "*.starJunctions.bed"
 
    input:
        val readCount

    script:

        String message = "There are not enough reads to proceed with this sample.  sampleId: " + params.sampleId + "  readCount: " + readCount

        """
        echo $message
        """
}

process REGISTER_LOW_READS {

    label "REGISTER_LOW_READS_$sampleId_$userId"

    publishDir "$sampleDirectory", mode:  'link', pattern: "*.starJunctions.bed"
 
    input:
        val readCount
        tuple val(sampleId), val(sampleDirectory), val(userId)

    script:

        String message = "There are not enough reads to proceed with this sample.  sampleId: " + sampleId + "  readCount: " + readCount

        """
        echo $message
        """
}

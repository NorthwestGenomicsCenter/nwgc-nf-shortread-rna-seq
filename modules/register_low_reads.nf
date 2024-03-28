process REGISTER_LOW_READS {

    executor 'local'

    tag "REGISTER_LOW_READS_${sampleId}_${userId}"

    publishDir "$publishDirectory", mode:  'link', pattern: "*.starJunctions.bed"
 
    input:
        val readCount
        tuple val(sampleId), val(publishDirectory), val(userId)

    script:

        String message = "There are not enough reads to proceed with this sample.  sampleId: " + sampleId + "  readCount: " + readCount

        """
        echo $message
        """
}

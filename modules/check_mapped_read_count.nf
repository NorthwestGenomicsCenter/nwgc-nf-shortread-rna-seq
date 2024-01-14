process CHECK_MAPPED_READ_COUNT {

    label "CHECK_MAPPED_READ_COUNT_${params.sampleId}_${params.userId}"

    input:
        path bam

    output:
        tuple val(readCount, val(readCountsPassed)) emit: results
        path "versions.yaml", emit: versions

    script:
        def readCount = "0"
        def readCountsPassed = false

        """
        ## Use samtools to find mapped reads (first try idxstats as it is faster)
        MAPPED_READS_FROM_SAMTOOLS=`samtools idxstats $BAM | awk '{sum+=\$3} {print sum}' | tail -n 1`
        if [ \$MAPPED_READS_FROM_SAMTOOLS == 0 ] ; then
            MAPPED_READS_FROM_SAMTOOLS=`samtools flagstat $BAM | head -n 5 |tail -n 1  | awk '{print \$1'}`
        fi

        $readCount = \$MAPPED_READS_FROM_SAMTOOLS
        $readCountsPassed = (\$MAPPED_READS_FROM_SAMTOOLS < 1000)
        """

}

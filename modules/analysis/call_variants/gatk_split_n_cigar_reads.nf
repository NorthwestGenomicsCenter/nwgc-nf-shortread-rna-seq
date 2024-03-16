process GATK_SPLIT_N_CIGAR_READS {

    label "GATK_SPLIT_N_CIGAR_READS_${params.sampleId}_${params.userId}"

    input:
        bam
        bai

    output:
        path "*.splitncigar.bam", emit: bam
        path "versions.yaml", emit: versions

    script:

        """
        gatk \
            -XX:InitialRAMPercentage=80 \
            -XX:MaxRAMPercentage=85 \
            SplitNCigarReads \
            -R ${params.starDirectory}/${params.referenceGenome} \
            --TMP_DIR . \
            -I $bam \
            -O ${params.sampleId}.splitncigar.bam

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}_${task.index}':
            gatk: \$(gatk --version | grep GATK | awk '{print \$6}')
        END_VERSIONS
        """

}

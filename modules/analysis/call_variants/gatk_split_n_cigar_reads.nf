process GATK_SPLIT_N_CIGAR_READS {

    tag "GATK_SPLIT_N_CIGAR_READS_${sampleId}_${userId}"

    input:
        tuple path(bam), path(bai)
        tuple val(starDirectory), val(referenceGenome), val(rsemReferencePrefix), val(gtfFile)
        tuple val(sampleId), val(publishDirectory), val(userId)

    output:
        tuple path("*.splitncigar.bam"), path("*.splitncigar.bai"), emit: bamTuple
        path "versions.yaml", emit: versions

    script:

        """
        gatk \
            --java-options "-XX:InitialRAMPercentage=80.0 -XX:MaxRAMPercentage=85.0" \
            SplitNCigarReads \
            -R ${starDirectory}/${referenceGenome} \
            --tmp-dir . \
            -I $bam \
            -O ${sampleId}.splitncigar.bam

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}_${task.index}':
            gatk: \$(gatk --version | grep GATK | awk '{print \$6}')
        END_VERSIONS
        """

}

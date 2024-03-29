process GATK_HAPLOTYPE_CALLER {

    tag "GATK_HAPLOTYPE_CALLER_${sampleId}_${userId}"

    input:
        tuple path(bam), path bai
        tuple val(starDirectory), val(referenceGenome), val(rsemReferencePrefix), val(gtfFile)
        tuple val(sampleId), val(publishDirectory), val(userId)

    output:
        tuple path  "*.vcf", path  "*.vcf.idx", emit: vcfTuple
        path "versions.yaml", emit: versions

    script:

        """
        gatk \
            --java-options "-XX:InitialRAMPercentage=80.0 -XX:MaxRAMPercentage=85.0" \
            HaplotypeCaller \
            -R ${starDirectory}/${referenceGenome} \
            -I $bam \
            -O ${sampleId}.vcf \
            --read-filter OverclippedReadFilter \
            --dont-require-soft-clips-both-ends \
            --dont-use-soft-clipped-bases \
            --minimum-mapping-quality 20 

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}':
            gatk: \$(gatk --version | grep GATK | awk '{print \$6}')
        END_VERSIONS

        """

}

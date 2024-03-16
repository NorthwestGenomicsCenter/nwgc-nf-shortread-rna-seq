process GATK_HAPLOTYPE_CALLER {

    label "GATK_HAPLOTYPE_CALLER_${params.sampleId}_${params.userId}"

    input:
        path bam
        path bai

    output:
        path  "*.vcf", emit: vcf
        path "versions.yaml", emit: versions

    script:

        """
        gatk \
            --java-options "-XX:InitialRAMPercentage=80 -XX:MaxRAMPercentage=85" \
            HaplotypeCaller \
            -R ${params.starDirectory}/${params.referenceGenome} \
            -I $bam \
            -O ${params.sampleId}.vcf
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

process GATK_VARIANT_FILTRATION {

    label "GATK_VARIANT_FILTRATION${params.sampleId}_${params.userId}"

    publishDir "${params.sampleDirectory}", mode:  'link', pattern: "*.filtered.vcf.gz"
    publishDir "${params.sampleDirectory}", mode:  'link', pattern: "*.filtered.vcf.gz.tbi"

    input:
        path vcf

    output:
        path  "*.filtered.vcf.gz", emit: filtered_vcf
        path  "*.filtered.vcf.gz.tbi", emit: filtered_vcf_index
        path "versions.yaml", emit: versions

    script:

        """
        gatk \
            --java-options "-XX:InitialRAMPercentage=80.0 -XX:MaxRAMPercentage=85.0" \
            VariantFiltration \
            -R ${params.starDirectory}/${params.referenceGenome} \
            -V $vcf \
            -O ${params.sampleId}.filtered.vcf \
            -window 35 \
            -cluster 3 \
            --filter-name FS -filter "FS > 30.0" \
            --filter-name QD -filter "QD < 2.0"

        bgzip -f ${params.sampleId}.filtered.vcf 
        tabix -p vcf -f ${params.sampleId}.filtered.vcf.gz

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}':
            gatk: \$(gatk --version | grep GATK | awk '{print \$6}')
        END_VERSIONS

        """

}

process GATK_VARIANT_FILTRATION {

    tag "GATK_VARIANT_FILTRATION_${sampleId}_${userId}"

    publishDir "${publishDirectory}", mode:  'link', pattern: "*.filtered.vcf.gz"
    publishDir "${publishDirectory}", mode:  'link', pattern: "*.filtered.vcf.gz.tbi"

    input:
        tuple path(vcf), path(vcf_index)
        tuple val(starDirectory), val(referenceGenome), val(rsemReferencePrefix), val(gtfFile)
        tuple val(sampleId), val(publishDirectory), val(userId)


    output:
        path  "*.filtered.vcf.gz", emit: filtered_vcf
        path  "*.filtered.vcf.gz.tbi", emit: filtered_vcf_index
        path "versions.yaml", emit: versions

    script:

        """
        gatk \
            --java-options "-XX:InitialRAMPercentage=80.0 -XX:MaxRAMPercentage=85.0" \
            VariantFiltration \
            -R ${starDirectory}/${referenceGenome} \
            -V $vcf \
            -O ${sampleId}.filtered.vcf \
            -window 35 \
            -cluster 3 \
            --filter-name FS -filter "FS > 30.0" \
            --filter-name QD -filter "QD < 2.0"

        bgzip -f ${sampleId}.filtered.vcf 
        tabix -p vcf -f ${sampleId}.filtered.vcf.gz

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}':
            gatk: \$(gatk --version | grep GATK | awk '{print \$6}')
        END_VERSIONS

        """

}

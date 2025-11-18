process RSEM {

    tag "RSEM_${sampleId}_${userId}"

    publishDir "${publishDirectory}", mode:  'link', pattern: "*.genes.results"
    publishDir "${publishDirectory}", mode:  'link', pattern: "*.genes.results.md5sum"
    publishDir "${publishDirectory}", mode:  'link', pattern: "*.isoforms.results"
    publishDir "${publishDirectory}", mode:  'link', pattern: "*.isoforms.results.md5sum"

    input:
        path transcriptomeBam
        tuple val(starDirectory), val(referenceGenome), val(rsemReferencePrefix), val(gtfFile)
        tuple val(sampleId), val(publishDirectory), val(userId)

    output:
        path "*.genes.results",  emit: genes
        path "*.genes.results.md5sum",  emit: genes_md5sum
        path "*.isoforms.results",  emit: isoforms
        path "*.isoforms.results.md5sum",  emit: isoforms_md5sum
        env  GENES_RESULTS_MD5SUM, emit: genes_md5sum_env
        env  ISOFORMS_RESULTS_MD5SUM, emit: isoforms_md5sum_env
        path "versions.yaml", emit: versions

    script:
        """
        rsem-calculate-expression \
            --num-threads $task.cpus \
            --fragment-length-max 1000 \
            --no-bam-output \
            --paired-end \
            --estimate-rspd \
            --forward-prob 0.0 \
            --bam $transcriptomeBam \
            ${starDirectory}/${rsemReferencePrefix} \
            ${sampleId}.transcriptome_hits.merged 

        GENES_RESULTS_MD5SUM=`md5sum ${sampleId}.transcriptome_hits.merged.genes.results | awk '{print \$1}'`
        echo \$GENES_RESULTS_MD5SUM  > ${sampleId}.transcriptome_hits.merged.genes.results.md5sum

        ISOFORMS_RESULTS_MD5SUM=`md5sum ${sampleId}.transcriptome_hits.merged.isoforms.results | awk '{print \$1}'`
        echo \$ISOFORMS_RESULTS_MD5SUM  > ${sampleId}.transcriptome_hits.merged.isoforms.results.md5sum

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}_${task.index}':
            rsem: \$( rsem-calculate-expression --version | awk '{print \$4}')
        END_VERSIONS
        """
}

process RSEM {

    tag "RSEM_${sampleId}_${userId}"

    publishDir "${publishDirectory}", mode:  'link', pattern: "*.genes.results"
    publishDir "${publishDirectory}", mode:  'link', pattern: "*.isoforms.results"
 
    input:
        path transcriptomeBam
        tuple val(starDirectory), val(referenceGenome), val(rsemReferencePrefix), val(gtfFile)
        tuple val(sampleId), val(publishDirectory), val(userId)

    output:
        path "*.genes.results",  emit: genes
        path "*.isoforms.results",  emit: isoforms
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
    
        cat <<-END_VERSIONS > versions.yaml
        '${task.process}_${task.index}':
            rsem: \$( rsem-calculate-expression --version | awk '{print \$4}')
        END_VERSIONS
        """
}

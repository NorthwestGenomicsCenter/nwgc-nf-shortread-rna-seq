process RSEM {

    label "RSEM_${params.sampleId}_${params.userId}"

    publishDir "${params.sampleDirectory}", mode:  'link', pattern: "*.genes.results"
    publishDir "${params.sampleDirectory}", mode:  'link', pattern: "*.isoforms.results"
 
    input:
        bam

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
            --bam $bam \
            ${params.starDirectory}/${params.rsemReferencePrefix} \
            ${params.sampleId}.transcriptome_hits.merged 
    
        cat <<-END_VERSIONS > versions.yaml
        '${task.process}_${task.index}':
            rsem: \$( rsem-calculate-expression --version | awk '{print \$4}')
        END_VERSIONS
        """
}

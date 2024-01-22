process RSEM {

    label "SAMBAMBA_SORT_${params.sampleId}_${params.userId}"

    publishDir "$params.sampleDirectory", mode:  'link', pattern: "*.genes.results"
    publishDir "$params.sampleDirectory", mode:  'link', pattern: "*..isoforms.results"
 
    input:
        path bam

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
            ${parms.starDirectory}/${params.rsemReferencePrefix}' \
            ${params.sampleId}.transcriptome_hits.merged 
    
    
           \$MOD_GSSAMBAMBA_DIR/bin/sambamba sort \
            --tmpdir $TMP \
            -t 6 \
            -o ${params.sampleId}.t.aligned.sortedByCoord.bam \
            $bam

        md5sum ${params.sampleId}.t.aligned.sortedByCoord.bam | awk '{print \$1}' > ${params.sampleId}.t.aligned.sortedByCoord.bam.md5sum


        cat <<-END_VERSIONS > versions.yaml
        '${task.process}_${task.index}':
            sambamba: \$(sambamba --version 2>&1 | awk 'NR==2 {print \$2}')
        END_VERSIONS
        """
}

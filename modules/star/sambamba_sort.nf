process SAMBAMBA_SORT {

    tag "SAMBAMBA_SORT_${sampleId}_${userId}"

    input:
        path bam
        tuple val(sampleId), val(publishDirectory), val(userId)

    output:
        tuple path("*.aligned.sortedByCoord.bam"), path("*.aligned.sortedByCoord.bam.bai"),  emit: sortedBamTuple
        path "versions.yaml", emit: versions

    script:
        """
        \$MOD_GSSAMBAMBA_DIR/bin/sambamba sort \
            --tmpdir $TMP \
            -t $task.cpus \
            -o ${sampleId}.aligned.sortedByCoord.bam \
            $bam

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}_${task.index}':
            sambamba: \$(sambamba --version 2>&1 | awk 'NR==2 {print \$2}')
        END_VERSIONS
        """
}

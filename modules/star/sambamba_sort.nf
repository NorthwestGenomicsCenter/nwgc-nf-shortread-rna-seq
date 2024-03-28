process SAMBAMBA_SORT {

    tag "SAMBAMBA_SORT_${sampleId}_${userId}"

    publishDir "$publishDirectory", mode:  'link', pattern: "*.aligned.sortedByCoord.bam"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.aligned.sortedByCoord.bam.bai"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.aligned.sortedByCoord.bam.md5sum"

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

        md5sum ${sampleId}.aligned.sortedByCoord.bam | awk '{print \$1}' > ${sampleId}.aligned.sortedByCoord.bam.md5sum


        cat <<-END_VERSIONS > versions.yaml
        '${task.process}_${task.index}':
            sambamba: \$(sambamba --version 2>&1 | awk 'NR==2 {print \$2}')
        END_VERSIONS
        """
}

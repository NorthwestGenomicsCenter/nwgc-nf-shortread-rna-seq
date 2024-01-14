process SAMBAMBA_SORT {

    label "SAMBAMBA_SORT_${params.sampleId}_${params.userId}"

    publishDir "$params.sampleDirectory", mode:  'link', pattern: "*.aligned.sortedByCoord.bam"
    publishDir "$params.sampleDirectory", mode:  'link', pattern: "*.aligned.sortedByCoord.bam.md5sum"

    input:
        path bam

    output:
        path "*.aligned.sortedByCoord.bam",  emit: sortedByCoordinate_bam
        path "versions.yaml", emit: versions

    script:
        """
        \$MOD_GSSAMBAMBA_DIR/bin/sambamba sort \
            --tmpdir $TMP \
            -t 6 \
            -o ${SAMPLE}.aligned.sortedByCoord.bam \
            $bam

        md5sum ${params.sampleId}.aligned.sortedByCoord.bam | awk '{print \$1}' > ${params.sampleId}.aligned.sortedByCoord.bam.md5sum


        cat <<-END_VERSIONS > versions.yaml
        '${task.process}_${task.index}':
            STAR: \$(sambamba --version 2>&1 | awk 'NR==2 {print \$2}'')
        END_VERSIONS
        """
}

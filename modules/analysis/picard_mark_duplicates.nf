process PICARD_MARK_DUPLICATES {

    tag "PICARD_MARK_DUPLICATES_${sampleId}_${userId}"

    publishDir "$publishDirectory", mode:  'link', pattern: "*.markeddups.bam", saveAs: {s-> "${sampleId}.accepted_hits.merged.markeddups.recal.bam"}
    publishDir "$publishDirectory", mode:  'link', pattern: "*.markeddups.bai", saveAs: {s-> "${sampleId}.accepted_hits.merged.markeddups.recal.bai"}
    publishDir "$publishDirectory", mode:  'link', pattern: "*.markeddups.bam.md5", saveAs: {s-> "${sampleId}.transcriptome_hits.merged.bam.md5"}

    input:
        tuple path(starBam), path(starBai)
        tuple val(sampleId), val(publishDirectory), val(userId)

    output:
        tuple path("${sampleId}.markeddups.bam"),  path("${sampleId}.markeddups.bai"), emit: bamTuple
        path "${sampleId}.markeddups.bam.md5", emit: md5
        path "versions.yaml", emit: versions

    script:

        """
        PICARD_TEMP_DIR=picard_temp
        mkdir -p "\$PICARD_TEMP_DIR"

        java \
            -XX:InitialRAMPercentage=80.0 \
            -XX:MaxRAMPercentage=85.0 \
            -jar \$PICARD_DIR/picard.jar \
            MarkDuplicates \
            --INPUT $starBam \
            --OUTPUT ${sampleId}.markeddups.bam \
            --METRICS_FILE ${sampleId}.duplicate_metrics.txt \
            --TMP_DIR \$PICARD_TEMP_DIR \
            --ASSUME_SORT_ORDER coordinate \
            --CREATE_MD5_FILE true \
            --CREATE_INDEX true \
            --QUIET false \
            --PROGRAM_RECORD_ID null \
            --REMOVE_DUPLICATES false \
            --COMPRESSION_LEVEL 5 

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}':
            java: \$(java -version 2>&1 | grep version | awk '{print \$3}' | tr -d '"''')
            picard: \$(java -jar \$PICARD_DIR/picard.jar MarkDuplicates --version 2>&1 | awk '{split(\$0,a,":"); print a[2]}')
        END_VERSIONS

        """

}

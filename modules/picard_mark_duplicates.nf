process PICARD_MARK_DUPLICATES {

    label "PICARD_MARK_DUPLICATES_${params.sampleId}_${params.userId}"

    publishDir "$params.sampleDirectory", mode:  'link', pattern: "*.markeddups.bam", saveAs: {s-> "${params.sampleId}.accepted_hits.merged.markeddups.recal.bam"}
    publishDir "$params.sampleDirectory", mode:  'link', pattern: "*.markeddups.bai", saveAs: {s-> "${params.sampleId}.accepted_hits.merged.markeddups.recal.bai"}
    publishDir "$params.sampleDirectory", mode:  'link', pattern: "*.markeddups.bam.md5sum", saveAs: {s-> "${params.sampleId}.transcriptome_hits.merged.bam.md5sum"}

    input:
        path bam
        path bai

    output:
        path "${params.sampleId}.markeddups.bam", emit: bam
        path "${params.sampleId}.markeddups.bai", emit: bai
        path "${params.sampleId}.markeddups.bam.md5sum", emit: md5
        path "versions.yaml", emit: versions

    script:

        """
        PICARD_TEMP__DIR=picard_temp
        mkdir -p "\$PICARD_TEMP__DIR"

        java \
            -XX:InitialRAMPercentage=80.0 \
            -XX:MaxRAMPercentage=85.0 \
            -jar \$PICARD_DIR/picard.jar \
            MarkDuplicates \
            $bam \
            --OUTPUT ${params.sampleId}.markeddups.bam \
            --METRICS_FILE ${params.sampleId}.duplicate_metrics.txt \
            --TMP-DIR \$PICARD_TEMP__DIR \
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

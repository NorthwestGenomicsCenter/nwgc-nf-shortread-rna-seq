process PICARD_INSERT_SIZE {

    label "PICARD_INSERT_SIZE_${params.sampleId}_${params.userId}"

    publishDir "$params.sampleQCDirectory", mode:  'link', pattern: "*.insert_size_metrics.txt"
    publishDir "$params.sampleQCDirectory", mode:  'link', pattern: "*.insert_size_histogram.png"

    input:
        path bam
        path bai

    output:
        path "${params.sampleId}.insert_size_metrics.txt", emit: metrics
        path "${params.sampleId}.insert_size_histogram.png", emit: histogram
        path "versions.yaml", emit: versions

    when:
        params.analysisToRun.contains("All") || params.analysisToRun.contains("QC")

    script:

        """
        PICARD_TEMP_DIR=picard_temp
        mkdir -p "\$PICARD_TEMP_DIR"

        java \
            -XX:InitialRAMPercentage=80.0 \
            -XX:MaxRAMPercentage=85.0 \
            -jar \$PICARD_DIR/picard.jar \
            CollectInsertSizeMetrics \
            --INPUT $bam \
            --OUTPUT ${params.sampleId}.insert_size_metrics.txt \
            --TMP_DIR \$PICARD_TEMP_DIR \
            --Histogram_FILE ${params.sampleId}.insert_size_histogram.pdf \
            --HISTOGRAM_WIDTH 1000 

        pdftoppm ${params.sampleId}.insert_size_histogram.pdf -png -scale-to 480 > ${params.sampleId}.insert_size_histogram.png

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}':
            java: \$(java -version 2>&1 | grep version | awk '{print \$3}' | tr -d '"''')
            picard: \$(java -jar \$PICARD_DIR/picard.jar MarkDuplicates --version 2>&1 | awk '{split(\$0,a,":"); print a[2]}')
        END_VERSIONS

        """

}

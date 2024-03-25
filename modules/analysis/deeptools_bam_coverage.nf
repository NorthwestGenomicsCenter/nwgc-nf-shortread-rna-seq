process DEEPTOOLS_BAM_COVERAGE {

    label "DEEPTOOLS_BAM_COVERAGE${params.sampleId}_${params.userId}"

    publishDir "${params.sampleBigWigDirectory}", mode:  'link', pattern: "*.bw"

    memory { 10.GB * (Math.pow(2, task.attempt - 1)) }
    errorStrategy { task.exitStatus == 137 ? 'retry' : 'terminate' }

    input:
        tuple (
            val(chromosome),
            val(strand),
            path(bam),
            path(bai)
        )

    output:
        path "*.bw", emit: bigwig
        path "versions.yaml", emit: versions

    script:

        """
        bamCoverage \
            --bam $bam \
            --region $chromosome \
            --filterRNAstrand $strand \
            --effectiveGenomeSize 2913022398 \
            --binSize 1 \
            --outFileFormat bigwig \
            --normalizeUsing RPGC \
            --numberOfProcessors 1 \
            --outFileName ${params.sampleId}.${chromosome}.${strand}.bw

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}':
            bamCoverage: \$(bamCoverage --version | awk '{print \$2}')
            python: \$(python --version | awk '{print \$2}')
        END_VERSIONS

        """

}

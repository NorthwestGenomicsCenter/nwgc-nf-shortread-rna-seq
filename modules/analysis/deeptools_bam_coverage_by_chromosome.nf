process DEEPTOOLS_BAM_COVERAGE {

    tag "DEEPTOOLS_BAM_COVERAGE_${sampleId}_${userId}_${chromosome}_${strand}_${task.index}"

    publishDir "${publishDirectory}", mode:  'link', pattern: "*.bw"
    publishDir "${publishDirectory}", mode:  'link', pattern: "*.bw.md5sum"

    memory { 10.GB * (Math.pow(2, task.attempt - 1)) }
 
    retryErrorCodes = [135, 137]
    errorStrategy { 
        if (retryErrorCodes.contains(task.exitStatus) || task.exitStatus == null) {
            if (task.attempt <= maxRetries ) {
                'retry'
            }
            else {
                'ignore'
            }
        }
        else {
            'terminate'
        }
    }

    input:
        tuple (
            val(chromosome),
            val(strand),
            path(bam),
            path(bai),
            val(publishDirectory),
            val(sampleId),
            val(sampleDirectory),
            val(userId)
        )
        val(effectiveGenomeSize)


    output:
        path "*.bw", emit: bigwig
        path "*.bw.md5sum", emit: bigwig_md5sum
        env  BIGWIG_MD5SUM, emit: bigwig_md5sum_env
        path "versions.yaml", emit: versions

    script:

        """
        bamCoverage \
            --bam $bam \
            --region $chromosome \
            --filterRNAstrand $strand \
            --effectiveGenomeSize $effectiveGenomeSize \
            --binSize 1 \
            --outFileFormat bigwig \
            --normalizeUsing RPGC \
            --numberOfProcessors 1 \
            --outFileName ${sampleId}.${chromosome}.${strand}.bw

        BIGWIG_MD5SUM=`md5sum ${sampleId}.${chromosome}.${strand}.bw | awk '{print \$1}'`
        echo \$BIGWIG_MD5SUM  > ${sampleId}.${chromosome}.${strand}.bw.md5sum

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}':
            bamCoverage: \$(bamCoverage --version | awk '{print \$2}')
            python: \$(python --version | awk '{print \$2}')
        END_VERSIONS

        """

}

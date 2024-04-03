process RNASEQC {

    tag "RNASEQC_${sampleId}_${userId}"

    publishDir "$publishDirectory", mode:  'link', pattern: "*.metrics.tsv"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.gene_tpm.gct"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.gene_reads.gct"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.gene_fragments.gct"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.exon_reads.gct"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.coverage.tsv"

    input:
        tuple path(bam), path(bai)
        tuple val(starDirectory), val(referenceGenome), val(rsemReferencePrefix), val(gtfFile)
        val publishDirectory
        tuple val(sampleId), val(publishDirectory), val(userId)

    output:
        path "*.metrics.tsv", emit: metrics
        path "*.gene_tpm.gct", emit: gene_tpm
        path "*.gene_reads.gct", emit: gene_reads
        path "*.gene_fragments.gct", emit: gene_fragments
        path "*.exon_reads.gct", emit: exon_reads
        path "*.coverage.tsv", emit: coverage
        path "versions.yaml", emit: versions

    script:

        """
        rnaseqc \
            ${starDirectory}/${gtfFile} \
            $bam \
            . \
            --sample=${sampleId} \
            --stranded=rf \
            --coverage \
            -v

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}':
            rnaseqc: \$(rnaseqc --version | awk '{print \$2}')
        END_VERSIONS

        """

}

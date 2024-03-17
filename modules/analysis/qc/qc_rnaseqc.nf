process RNASEQC {

    label "RNASEQC_${params.sampleId}_${params.userId}"

    publishDir "$params.sampleQCDirectory", mode:  'link', pattern: "*.metrics.tsv"
    publishDir "$params.sampleQCDirectory", mode:  'link', pattern: "*.gene_tpm.gct"
    publishDir "$params.sampleQCDirectory", mode:  'link', pattern: "*.gene_reads.gct"
    publishDir "$params.sampleQCDirectory", mode:  'link', pattern: "*.gene_fragments.gct"
    publishDir "$params.sampleQCDirectory", mode:  'link', pattern: "*.exon_reads.gct"

    input:
        path bam
        path bai

    output:
        path "*.metrics.tsv", emit: metrics
        path "*.gene_tpm.gct", emit: gene_tpm
        path "*.gene_reads.gct", emit: gene_reads
        path "*.gene_fragments.gct", emit: gene_fragments
        path "*.exon_reads.gct", emit: exon_reads
        path "versions.yaml", emit: versions

    script:

        """
        rnaseqc \
            ${params.starDirectory}/${params.gtfFile} \
            $bam \
            . \
            --sample=${params.sampleId} \
            --stranded=rf \
            --coverage \
            -v

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}':
            rnaseqc: \$(rnaseqc --version | awk '{print \$2}')
        END_VERSIONS

        """

}

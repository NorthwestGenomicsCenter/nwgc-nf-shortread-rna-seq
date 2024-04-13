process RNASEQC {

    tag "RNASEQC_${sampleId}_${userId}"

    publishDir "$publishDirectory", mode:  'link', pattern: "*.metrics.tsv"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.metrics.tsv.md5sum"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.gene_tpm.gct"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.gene_tpm.gct.md5sum"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.gene_reads.gct"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.gene_reads.gct.md5sum"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.gene_fragments.gct"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.gene_fragments.gct.md5sum"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.exon_reads.gct"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.exon_reads.gct.md5sum"
    publishDir "$publishDirectory", mode:  'link', pattern: "*.coverage.tsv"

    input:
        tuple path(bam), path(bai)
        tuple val(starDirectory), val(referenceGenome), val(rsemReferencePrefix), val(gtfFile)
        val publishDirectory
        tuple val(sampleId), val(sampleDirectory), val(userId)

    output:
        path "*.metrics.tsv", emit: metrics
        env  METRICS_MD5SUM, emit: metrics_md5sum
        path "*.gene_tpm.gct", emit: gene_tpm
        env  GENE_TPM_MD5SUM, emit: gene_tpm_md5sum
        path "*.gene_reads.gct", emit: gene_reads
        env  GENE_READS_MD5SUM, emit: gene_reads_md5sum
        path "*.gene_fragments.gct", emit: gene_fragments
        env  GENE_FRAGMENTS_MD5SUM, emit: gene_fragments_md5sum
        path "*.exon_reads.gct", emit: exon_reads
        env  EXON_READS_MD5SUM, emit: exon_reads_md5sum
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

        METRICS_MD5SUM=`md5sum ${sampleId}.metrics.tsv | awk '{print \$1}'`
        echo \$METRICS_MD5SUM  > ${sampleId}.metrics.tsv.md5sum

        GENE_TPM_MD5SUM=`md5sum ${sampleId}.gene_tpm.gct | awk '{print \$1}'`
        echo \$GENE_TPM_MD5SUM  > ${sampleId}.gene_tpm.gct.md5sum

        GENE_READS_MD5SUM=`md5sum ${sampleId}.gene_reads.gct | awk '{print \$1}'`
        echo \$GENE_READS_MD5SUM  > ${sampleId}.gene_reads.gct.md5sum

        GENE_FRAGMENTS_MD5SUM=`md5sum ${sampleId}.gene_fragments.gct | awk '{print \$1}'`
        echo \$GENE_FRAGMENTS_MD5SUM  > ${sampleId}.gene_fragments.gct.md5sum

        EXON_READS_MD5SUM=`md5sum ${sampleId}.exon_reads.gct | awk '{print \$1}'`
        echo \$EXON_READS_MD5SUM  > ${sampleId}.exon_reads.gct.md5sum

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}':
            rnaseqc: \$(rnaseqc --version | awk '{print \$2}')
        END_VERSIONS

        """

}

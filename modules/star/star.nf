process STAR {

    tag "STAR_${sampleId}_${userId}"

    publishDir "${publishDirectory}", mode:  'link', pattern: "*.Aligned.toTranscriptome.out.bam", saveAs: {s-> "${sampleId}.transcriptome_hits.merged.bam"}
    publishDir "${publishDirectory}", mode:  'link', pattern: "*.Aligned.toTranscriptome.out.bam.md5sum", saveAs: {s-> "${sampleId}.transcriptome_hits.merged.bam.md5sum"}
    publishDir "${publishDirectory}", mode:  'link', pattern: "*.ReadsPerGene.out.tab"
    publishDir "${publishDirectory}", mode:  'link', pattern: "*.ReadsPerGene.out.tab.md5sum"
    publishDir "${publishDirectory}", mode:  'link', pattern: "*.SJ.out.tab"
    publishDir "${publishDirectory}", mode:  'link', pattern: "*.SJ.out.tab.md5sum"

    input:
        tuple val(fastq1Files), val(fastq2Files), val(readGroups)
        tuple val(starDirectory), val(referenceGenome), val(rsemReferencePrefix), val(gtfFile)
        tuple val(sampleId), val(publishDirectory), val(userId)

    output:
        path "*.Aligned.out.bam",  emit: aligned_bam
        path "*.Aligned.toTranscriptome.out.bam", emit: transcriptome_bam
        path "*.Aligned.toTranscriptome.out.bam.md5sum", emit: transcriptome_bam_md5sum
        path "*.ReadsPerGene.out.tab", emit: readsPerGene_tab
        path "*.ReadsPerGene.out.tab.md5sum", emit: readsPerGene_tab_md5sum
        path "*.SJ.out.tab", emit: spliceJunctions_tab
        path "*.SJ.out.tab.md5sum", emit: spliceJunctions_tab_md5sum
        env  READS_PER_GENE_MD5SUM, emit: readsPerGene_tab_md5sum_env
        env  TRANSCRIPTOME_BAM_MD5SUM, emit: transcriptome_bam_md5sum_env
        env  SJ_MD5SUM, emit: spliceJunctions_tab_md5sum_env
        path "versions.yaml", emit: versions

    script:
        """
        STAR \
            --runMode alignReads \
            --runThreadN ${task.cpus} \
            --genomeDir $starDirectory \
            --twopassMode Basic \
            --alignSJoverhangMin 8 \
            --alignSJDBoverhangMin 1 \
            --outFilterMultimapNmax 20 \
            --outFilterMismatchNmax 999 \
            --outFilterMismatchNoverLmax 0.1 \
            --alignIntronMin 20 \
            --alignIntronMax 1000000 \
            --alignMatesGapMax 1000000 \
            --outFilterType BySJout \
            --outFilterScoreMinOverLread 0.33 \
            --outFilterMatchNminOverLread 0.33 \
            --limitSjdbInsertNsj 1200000 \
            --readFilesIn $fastq1Files $fastq2Files \
            --readFilesCommand zcat \
            --outFileNamePrefix "${sampleId}." \
            --outSAMstrandField intronMotif \
            --outFilterIntronMotifs None \
            --alignSoftClipAtReferenceEnds Yes \
            --quantMode TranscriptomeSAM GeneCounts \
            --outSAMtype BAM Unsorted \
            --outSAMunmapped Within \
            --genomeLoad NoSharedMemory \
            --chimSegmentMin 15 \
            --chimJunctionOverhangMin 15 \
            --chimOutType Junctions WithinBAM SoftClip \
            --chimMainSegmentMultNmax 1 \
            --outSAMattributes NH HI AS nM NM ch \
            --outSAMattrRGline $readGroups \
            --outTmpDir starTempDir

        TRANSCRIPTOME_BAM_MD5SUM=`md5sum ${sampleId}.Aligned.toTranscriptome.out.bam | awk '{print \$1}'`
        echo \$TRANSCRIPTOME_BAM_MD5SUM  > ${sampleId}.Aligned.toTranscriptome.out.bam.md5sum

        READS_PER_GENE_MD5SUM=`md5sum ${sampleId}.ReadsPerGene.out.tab | awk '{print \$1}'`
        echo \$READS_PER_GENE_MD5SUM > ${sampleId}.ReadsPerGene.out.tab.md5sum

        SJ_MD5SUM=`md5sum ${sampleId}.SJ.out.tab | awk '{print \$1}'`
        echo \$SJ_MD5SUM > ${sampleId}.SJ.out.tab.md5sum

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}_${task.index}':
            STAR: \$(STAR --version)
        END_VERSIONS
        """
}

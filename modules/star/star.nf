process STAR {

    label "STAR_${params.sampleId}_${params.userId}"

    publishDir "${params.sampleDirectory}", mode:  'link', pattern: "*.Aligned.out.bam"
    publishDir "${params.sampleDirectory}", mode:  'link', pattern: "*.Aligned.toTranscriptome.out.bam", saveAs: {s-> "${params.sampleId}.transcriptome_hits.merged.bam"}
    publishDir "${params.sampleDirectory}", mode:  'link', pattern: "*.Aligned.toTranscriptome.out.bam.md5sum", saveAs: {s-> "${params.sampleId}.transcriptome_hits.merged.bam.md5sum"}
    publishDir "${params.sampleDirectory}", mode:  'link', pattern: "*.ReadsPerGene.out.tab"
    publishDir "${params.sampleDirectory}", mode:  'link', pattern: "*.SJ.out.tab"

    input:
        fastq1Files
        fastq2Files
        readGroups

    output:
        path "*.Aligned.out.bam",  emit: aligned_bam
        path "*.Aligned.toTranscriptome.out.bam", emit: transcriptome_bam
        path "*.ReadsPerGene.out.tab", emit: readsPerGene_tab
        path "*.SJ.out.tab", emit: spliceJunctions_tab
        path "versions.yaml", emit: versions

    script:
        """
        STAR \
            --runMode alignReads \
            --runThreadN ${task.cpus} \
            --genomeDir ${params.starDirectory} \
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
            --outFileNamePrefix "${params.sampleId}." \
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

        md5sum ${params.sampleId}.Aligned.toTranscriptome.out.bam | awk '{print \$1}' > ${params.sampleId}.Aligned.toTranscriptome.out.bam.md5sum

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}_${task.index}':
            STAR: \$(STAR --version)
        END_VERSIONS
        """
}

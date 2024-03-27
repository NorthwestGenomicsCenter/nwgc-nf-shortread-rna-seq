include { STAR_MAP_MERGE_SORT } from './workflows/star_map_merge_sort.nf'
include { ANALYSIS } from './workflows/analysis.nf'
include { REGISTER_LOW_READS } from  './modules/register_low_reads.nf'

workflow {

    // Create params channels
    Integer lowReadsTreshold = params.lowReadsThreshold.toInteger()

    // Versions channel
    ch_versions = Channel.empty()
    ch_analysisInput = Channel.empty()

    // Fastqs channel
    ch_fastqs =
        Channel.from(params.fastqs)
            .map{ row ->
                String fastq1Files = row.fastq1Files
                String fastq2Files = row.fastq2Files
                String readGroups = row.readGroups

                return tuple(fastq1Files, fastq2Files, readGroups)
            }

    // Map/Merge using STAR
    STAR_MAP_MERGE_SORT(ch_fastqs)
    ch_versions = ch_versions.mix(STAR_MAP_MERGE_SORT.out.versions)

    // If not enough reads, write early exit message to stdout
    ch_lowReads = STAR_MAP_MERGE_SORT.out.readCount.filter{readCount -> readCount.toInteger() < lowReadsTreshold}
    REGISTER_LOW_READS(ch_lowReads)

    // Star Bam Channel
    ch_starBam = STAR_MAP_MERGE_SORT.out.starTuple.filter{starBam, starBai, readCount -> readCount.toInteger() >= lowReadsTreshold}
    if (!params.fastqs && params.analysisStarBam {
        ch_starBam =
            Channel.from(params.analysisStarBam)
                .map{ row ->
                    Path starBam = file(row.starBam)
                    Path starBai = file(row.starBam + ".bai")

                    return tuple(starBam, starBai)
                }
    }
T
    // Transcriptome Bam Channel
    ch_transcriptomeBam = STAR_MAP_MERGE_SORT.out.transcriptomeTuple.filter{transcriptomeBam, readCount -> readCount.toInteger() >= lowReadsTreshold}
    if (!params.fastqs && params.analysisTranscriptomeBam {
        ch_transcriptomeBam = Channel.from(params.analysisTranscriptomeBam)
    }

    // Junctions Bed Channel
    ch_junctionsBed = STAR_MAP_MERGE_SORT.out.junctionsTuple.filter{junctionsBed, readCount -> readCount.toInteger() >= lowReadsTreshold}
    if (!params.fastqs && params.analysisJunctionBed{
        ch_junctionsBed = Channel.from(params.analysisJunctionBed)
    }

    // Analysis
    ANALYSIS(ch_starBam, ch_transcriptomeBam, ch_junctionsBed)
    ch_versions = ch_versions.mix(ANALYSIS.out.versions)

    ch_versions.unique().collectFile(name: 'rna-star_software_versions.yaml', storeDir: "${params.sampleDirectory}")

}

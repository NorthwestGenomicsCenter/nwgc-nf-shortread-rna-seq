include { STAR_MAP_MERGE_SORT } from './workflows/star_map_merge_sort.nf'
include { ANALYSIS } from './workflows/analysis.nf'

workflow {

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

    // Verify read count is high enough to proceed
    read_count_ch = STAR_MAP_MERGE_SORT.out.analysisTuple
      .branch {starBam, starBai, transcriptomeBam, junctionsTab, readCount ->
            pass: readCount.isInteger() && readCount.toInteger() >= 1000
            fail: !readCount.isInteger() || readCount.toInteger() < 1000
      }

    // If not enough reads, write early exit message to stdout
    read_count_ch.fail.view()

    // Analysis input channel
    ch_analysisInput = read_count_ch.pass
    if (!params.fastqs && params.analysis) {
        ch_analysisInput =
            Channel.from(params.analysis)
                .map{ row ->
                    Optional<Path> starBam = row.star.bam ? file(row.starBam) : Optional.empty()
                    Optional<Path> starBai = row.starBam ? file(row.starBam + ".bai") : Optional.empty()
                    Optional<Path> transcriptomeBam = row.transcriptomeBam ? file(row.transcriptomeBam) : Optional.empty()
                    Optional<Path> spliceJunctionsTab = row.spliceJunctionsTab ? file(row.spliceJunctionsTab) : Optional.empty()

                    return tuple(starBam, starBai, transcriptomeBam, spliceJunctionsTab)
                }
    }

    // Analysis
    ANALYSIS(ch_analysisInput)
    ch_versions = ch_versions.mix(ANALYSIS.out.versions)

    ch_versions.unique().collectFile(name: 'rna-star_software_versions.yaml', storeDir: "${params.sampleDirectory}")

}

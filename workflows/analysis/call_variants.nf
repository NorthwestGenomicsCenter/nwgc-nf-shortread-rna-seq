include { GATK_SPLIT_N_CIGAR_READS } from '../../modules/analysis/call_variants/gatk_split_n_cigar_reads.nf'
include { GATK_HAPLOTYPE_CALLER } from '../../modules/analysis/call_variants/gatk_haplotype_caller.nf'
include { GATK_VARIANT_FILTRATION } from '../../modules/analysis/call_variants/gatk_variant_filtration.nf'

workflow CALL_VARIANTS {

    take:
        markedDupsBam
        markedDupsBai

    main:

        GATK_SPLIT_N_CIGAR_READS(markedDupsBam, markedDupsBai)
        GATK_HAPLOTYPE_CALLER(GATK_SPLIT_N_CIGAR_READS.out.bam, GATK_SPLIT_N_CIGAR_READS.out.bai)
        GATK_VARIANT_FILTRATION(GATK_HAPLOTYPE_CALLER.out.vcf, GATK_HAPLOTYPE_CALLER.out.vcf_index)

        // Versions
        ch_versions = Channel.empty()
        ch_versions = ch_versions.mix(GATK_SPLIT_N_CIGAR_READS.out.versions)
        ch_versions = ch_versions.mix(GATK_HAPLOTYPE_CALLER.out.versions)
        ch_versions = ch_versions.mix(GATK_VARIANT_FILTRATION.out.versions)

    emit:
        versions = ch_versions

}

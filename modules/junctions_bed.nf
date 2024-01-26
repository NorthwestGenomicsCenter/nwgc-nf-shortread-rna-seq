process JUNCTIONS_BED {

    label "JUNCTIONS_BED_${params.sampleId}_${params.userId}"

    publishDir "$params.sampleDirectory", mode:  'link', pattern: "*.starJunctions.bed"
 
    input:
        path spliceJunctions_tab

    output:
        path "*.starJunctions.bed",  emit: junctions_bed
        path "versions.yaml", emit: versions

    script:
        """
        ## column 1: chromosome
        ## column 2: first base of the intron (1-based)
        ## column 3: last base of the intron (1-based)
        ## column 4: strand (0: undefined, 1: +, 2: -)
        ## column 5: intron motif: 0: non-canonical; 1: GT/AG, 2: CT/AC, 3: GC/AG, 4: CT/GC, 5:AT/AC, 6: GT/AT
        ## column 6: 0: unannotated, 1: annotated (only if splice junctions database is used) 10
        ## column 7: number of uniquely mapping reads crossing the junction
        ## column 8: number of multi-mapping reads crossing the junction
        ## column 9: maximum spliced alignment overhang
        ## cols 1-6 define a merged unit
        ## cols 7,8 are summed in the merge
        ## cols 9 are maxed in the merge

        awk \
            '{ if($4==1 && $5==1) print $1"\t"$2"\t"$3"\tGT-AG_"$1":"$2"-"$3";"$7"\t"$7"\t+"; \
                else if($4==1 && $5==2) print $1"\t"$2"\t"$3"\tCT-AC_"$1":"$2"-"$3";"$7"\t"$7"\t+"; \
                else if($4==1 && $5==3) print $1"\t"$2"\t"$3"\tGC-AG_"$1":"$2"-"$3";"$7"\t"$7"\t+"; \
                else if($4==1 && $5==4) print $1"\t"$2"\t"$3"\tCT-GC_"$1":"$2"-"$3";"$7"\t"$7"\t+"; \
                else if($4==1 && $5==5) print $1"\t"$2"\t"$3"\tAT-AC_"$1":"$2"-"$3";"$7"\t"$7"\t+"; \
                else if($4==1 && $5==6) print $1"\t"$2"\t"$3"\tGT-AT_"$1":"$2"-"$3";"$7"\t"$7"\t+"; \
                else if($4==2 && $5==1) print $1"\t"$2"\t"$3"\tGT-AG_"$1":"$2"-"$3";"$7"\t"$7"\t-"; \
                else if($4==2 && $5==2) print $1"\t"$2"\t"$3"\tCT-AC_"$1":"$2"-"$3";"$7"\t"$7"\t-"; \
                else if($4==2 && $5==3) print $1"\t"$2"\t"$3"\tGC-AG_"$1":"$2"-"$3";"$7"\t"$7"\t-"; \
                else if($4==2 && $5==4) print $1"\t"$2"\t"$3"\tCT-GC_"$1":"$2"-"$3";"$7"\t"$7"\t-"; \
                else if($4==2 && $5==5) print $1"\t"$2"\t"$3"\tAT-AC_"$1":"$2"-"$3";"$7"\t"$7"\t-"; \
                else if($4==2 && $5==6) print $1"\t"$2"\t"$3"\tGT-AT_"$1":"$2"-"$3";"$7"\t"$7"\t-" \
            }' \
            $spliceJunctions_tab \
            > ${params.sampleId}.starJunctions.bed
    
        cat <<-END_VERSIONS > versions.yaml
        '${task.process}_${task.index}':
            awk: \$(awk --version | awk 'NR==1 {print \$3}')
        END_VERSIONS
        """
}

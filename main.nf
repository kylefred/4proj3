#!/usr/bin/env nextflow

params.abs_dir = 'data/abs*'
params.inst_dir = 'data/InstitutionCampus.csv'
params.out_dir = 'output/'

abs_channel = Channel.fromPath( params.abs_dir )
inst_channel = Channel.fromPath( params.inst_dir )

process get_collaborators {
    container 'rocker/tidyverse'

    input:
    file f from abs_channel.combine( inst_channel )

    output:
    file "collab.csv" into collab_channel

    """
    Rscript $baseDir/bin/get_collabs.R $f
    """
}

process rank_collaborators {
    container 'rocker/tidyverse'
    publishDir baseDir
 
    input:
    file c from collab_channel.collectFile(name: 'all_collabs.csv', newLine: true)

    output:
    file "ranked.csv" into output_channel

    """
    Rscript $baseDir/bin/rank_collabs.R $c
    """
}

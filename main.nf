#!/usr/bin/env nextflow

params.file_dir = 'data/abs*'
params.out_dir = 'output/'
params.out_file = 'histogram.png'

file_channel = Channel.fromPath( params.file_dir )

process get_collaborators {
    container 'rocker/tidyverse'

    input:
    file abstract from file_channel

    output:
    file "out.csv" into collab.channel

    """
    Rscript $baseDir/bin/get_collabs.R $abstract
    """
}

#!/usr/bin/env nextflow

params.file_dir = 'abstracts/'
params.out_dir = 'data/'
params.out_file = 'histogram.png'

file_channel = Channel.fromPath( params.file_dir )

process get_collaborators {
    container 'rocker/tidyverse:3.5'

    input:
    file abstract from file_channel

    output:
    

    """
    Rscript makecsvs abstract
    """
}

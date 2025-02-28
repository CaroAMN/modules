
process MICROSAM {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/micro-sam':
        'biocontainers/micro-sam:1.1.1_cv1' }" 

    //container "microsam_biocon:latest"

    input:
    tuple val(meta), path(image)

    output:
    tuple val(meta), path("*mask.tif")  , emit: mask
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // Version information not provided by the tool on CLI 
    def VERSION = '1.1.1'
    
    """
    micro_sam.automatic_segmentation \\
        --input_path $image \\
        --output_path ${prefix}_mask.tif \\
        $args \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        microsam: $VERSION
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // Version information not provided by the tool on CLI 
    def VERSION = '1.1.1'
    """
    touch ${prefix}_mask.tif

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        microsam: $VERSION
    END_VERSIONS
    """
}

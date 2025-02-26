
process MICROSAM {
    tag "$meta.id"
    label 'process_single'

    // TODO nf-core: List required Conda package(s).
    //               Software MUST be pinned to channel (i.e. "bioconda"), version (i.e. "1.10").
    //               For Conda, the build (i.e. "h9402c20_2") must be EXCLUDED to support installation on different operating systems.
    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    //conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //    'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
    //    'biocontainers/YOUR-TOOL-HERE' }"
    container "microsam_biocon:latest"

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
    
    // TODO nf-core: If the tool supports multi-threading then you MUST provide the appropriate parameter
    //               using the Nextflow "task" variable e.g. "--threads $task.cpus"
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

workflow SctkDoubletCells {
    
    # An integer matrix of counts
    File raw_counts

    call runDoubletCells {
        input:
            raw_counts = raw_counts
    }

    output {
        File doublet_removed_counts = runDoubletCells.output_counts
        File doublet_ids = runDoubletCells.output_ids
    }
}

task runDoubletCells {
    File raw_counts

    String output_name_prefix = "sctk_doublet_cells_reduced_counts"
    String doublet_file_prefix = "sctk_doublet_cells_ids"

    Int disk_size = 20

    command {
        Rscript /opt/software/doubletcells_qc.R \
        -f ${raw_counts} \
        -o ${output_name_prefix} \
        -d ${doublet_file_prefix}
    }

    output {
        File output_counts = glob("${output_name_prefix}*")[0]
        File output_ids = glob("${doublet_file_prefix}*")[0]
    }

    runtime {
        docker: "ghcr.io/web-mev/mev-sctk-doubletcells"
        cpu: 2
        memory: "16 G"
        disks: "local-disk " + disk_size + " HDD"
    }
}

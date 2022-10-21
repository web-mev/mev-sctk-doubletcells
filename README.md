# mev-sctk-doubletcells

This repository contains a WDL-format Cromwell-compatible workflow for executing the DoubletCells method of scran (https://bioconductor.org/packages/3.10/bioc/html/scran.html) for single-cell RNA-seq data as provided through the Single-Cell Toolkit (https://github.com/compbiomed/singleCellTK).

Outputs include a file containing the barcodes of likely doublets/multiplets *and* a count matrix subset where those cell barcodes have been removed.

To use, simply fill in the the `inputs.json` with the path to the single-cell counts file and submit to a Cromwell job runner.

Alternatively (if you do not want to use Cromwell), you can pull the docker image (https://github.com/web-mev/mev-sctk-doubletcells/pkgs/container/mev-sctk-doubletcells), start the container, and run: 

```
Rscript /opt/software/sctk_dimreduce.R \
    <path to raw counts tab-delimited file> \
    <number of PCA dimensions, as integer> \
    <path to output filename>

Rscript /opt/software/doubletcells_qc.R \
    -f <path to raw counts tab-delimited file> \
    -o <prefix (string) for the subsetted count matrix filename> \
    -d <prefix (string) for the multiplet barcodes filename>
```
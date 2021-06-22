suppressMessages(suppressWarnings(library("singleCellTK")))
suppressMessages(suppressWarnings(library("Matrix")))
suppressMessages(suppressWarnings(library("optparse")))

# args from command line:
args<-commandArgs(TRUE)

option_list <- list(
    make_option(
        c('-f','--input_file'),
        help='Path to the count matrix input.'
    ),
    make_option(
        c('-o','--output_file_prefix'),
        help='The prefix for the output file'
    ),
    make_option(
        c('-d', '--doublet_file_prefix'),
        help = 'The prefix for the doublet class file'
    )
)

opt <- parse_args(OptionParser(option_list=option_list))

# Check that the file was provided:
if (is.null(opt$input_file)){
    message('Need to provide a count matrix with the -f/--input_file arg.')
    quit(status=1)
}

if (is.null(opt$output_file_prefix)) {
    message('Need to provide the prefix for the output file with the -o arg.')
    quit(status=1)
}

# Define the appended filename
method_str <- "DoubletCells_filtered"

# Import counts as a data.frame
cnts <- read.table(
    file = opt$input_file,
    sep = "\t",
    row.names = 1,
    header=T
)

# change to a sparse matrix representation, necessary for SCE
cnts <- as(as.matrix(cnts), "sparseMatrix")

# Create an SCE object from the counts
sce <- SingleCellExperiment(
    assays=list(counts=cnts)
)

# Run DoubletCells on the sce object.
sce <- runDoubletCells(
    sce,
    nNeighbors = 50,
    simDoublets = 10000
)

# Create a data frame from the DoubletCells factors and the SCE object
# cell barcodes
df.doublets <- data.frame(
    cell_barcode = as.vector(colnames(cnts)),
    doublet_class = as.vector(sce$scran_doubletCells_class)
)

# Export doublet classification to file
doublet_filename <- paste(opt$doublet_file_prefix, method_str, 'tsv', sep='.')
write.table(
    df.doublets,
    doublet_filename,
    sep = "\t",
    quote = F,
    row.names = F
)

# Create a subset SCE object by filtering for singlets
sce.sub <- subsetSCECols(
    sce,
    colData = "scran_doubletCells_class == 'singlet'"
)

# Export count matrix to file
output_cnts <- data.frame(as.matrix(counts(sce.sub)))
rownames(output_cnts) <- rownames(counts(sce.sub))
output_filename <- paste(opt$output_file_prefix, method_str, 'tsv', sep='.')
write.table(
    output_cnts,
    output_filename,
    sep = "\t",
    quote = F,
    row.names = T
)
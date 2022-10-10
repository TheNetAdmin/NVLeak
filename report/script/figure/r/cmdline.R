suppressPackageStartupMessages(library(optparse))

option_list <- list(
    make_option(
        c("-d", "--data"),
        type = "character",
        help = "dataset file name",
        metavar = "character"
    ),
    make_option(
        c("-o", "--out"),
        type = "character",
        help = "output file name",
        metavar = "character"
    ),
    make_option(
        c("-t", "--type"),
        type = "character",
        help = "output file type [tikz|pdf]",
        metavar = "character"
    )
);

if (exists("additional_option_list")) {
    option_list <- append(option_list, additional_option_list)
}

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$data) && is.null(opt$out) && is.null(opt$type)) {
    print("NOTE: no cli option provided")
} else if (is.null(opt$data) || is.null(opt$out) || is.null(opt$type)) {
    stop("Some arguments are missing", call. = print_help(opt_parser))
}

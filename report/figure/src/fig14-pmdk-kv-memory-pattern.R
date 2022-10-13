suppressPackageStartupMessages(library(optparse))
additional_option_list <- list(
    make_option(
        c("-a", "--arg"),
        type = "integer",
        help = "optional additional arg",
        metavar = "number"
    )
)
source("../script/figure/r/cmdline.R")
source("../script/figure/r/common.R")

df <- read_data(opt$data)

x_length <- 100
# x_length <- 25

fig_width <- fig_half_width
fig_height <- 1.5 * fig_half_width

if (opt$arg == 0) {
    x_start <- 0
    x_length <- 4096
    fig_width <- fig_half_width * 10
} else if (opt$arg == 256) {
    x_start <- 300
    # x_start <- 325
} else if (opt$arg == 512) {
    x_start <- 650
    # x_start <- 700
} else if (opt$arg == 768) {
    x_start <- 1050
    # x_start <- 1100
} else if (opt$arg == 1024) {
    x_start <- 1450
    # x_start <- 1475
} else {
    stop("arg value is invalid")
}

output_dev(opt$type, opt$out, fig_width, fig_height)

df %>%
    filter(iter >= x_start) %>%
    filter(iter <= x_start + x_length) %>%
    filter(frac_median >= 1.05) %>%
    filter(frac_median <= 1.50) %>%
    mutate(iter = iter - x_start) %>%
naplot(
    text = element_text(size = 25)
) +
    geom_point(
        aes(
            x = iter,
            y = set
        ),
        size = 1
    ) +
    scale_x_continuous(
        name = "Iter"
    ) +
    scale_y_continuous(
        name = "Set",
        breaks = c(0, 64, 128, 192, 256),
        limits = c(0, 256)
    )

output_dev_close()

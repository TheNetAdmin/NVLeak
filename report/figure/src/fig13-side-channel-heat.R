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


if (opt$arg == 1) {
    df <- read_data(opt$data) %>%
        filter(lat <= 1200)
    x_break <- c(0, 64, 128, 192, 256)
    y_break <- c(0, 64, 128, 192, 256)
    legend_position <- "none"
} else {
    df <- read_data(opt$data) %>%
        filter(iter <= 40000) %>%
        filter(lat < 1000)
    x_break <- c(0, 10000, 10000 * 2, 10000 * 3, 10000 * 4)
    y_break <- c(0, 64, 128, 192, 256)
    legend_position <- "top"
}

output_dev(opt$type, opt$out, fig_half_width, fig_full_height)
df %>%
    naplot(
        legend.position = legend_position,
        legend.key.height = unit(8, "pt"),
        panel.grid.major.y = NULL,
        panel.grid.minor.y = NULL,
        panel.grid.major.x = NULL,
        panel.grid.minor.x = NULL
    ) +
    scale_color_material("indigo") +
    scale_fill_material("indigo") +
    geom_tile(aes(x = iter, y = set, fill = lat)) +
    labs(x = "Probe iteration", y = "NVCache set index") +
    scale_x_continuous(breaks = x_break) +
    scale_y_continuous(breaks = y_break) +
    labs(fill = "Latency (cycle)")
output_dev_close()

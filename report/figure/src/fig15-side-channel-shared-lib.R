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

fig_width <- fig_full_width
fig_height <- 1.2 * fig_full_height

if (opt$arg == 0) {
    # Full output
    iter_beg <- 0
    iter_end <- 1200 * 600
    # iter_beg <- 146800
    # iter_end <- 147200
    x_breaks <- seq(0, 12000, iter_end)
    x_limits <- c(0, iter_end - iter_beg)
    y_limits <- c(0, 2000)
    fig_width <- fig_width * 10
} else if (opt$arg == 1) {
    # 20220606-21-11-23
    iter_beg <- 286000
    iter_end <- 296000
    x_breaks <- seq(0, 10000, 2000)
    x_limits <- c(0, 10000)
    y_limits <- c(200, 1000)
} else if (opt$arg == 2) {
   # 20220607-11-40-27
    iter_beg <- 287050
    iter_end <- iter_beg + 160
    x_breaks <- seq(0, iter_end - iter_beg, 40)
    x_limits <- c(0, iter_end - iter_beg)
    y_limits <- c(200, 1000)
} else if (opt$arg == 3) {
    iter_beg <- 146500
    iter_end <- 147500
    x_breaks <- seq(0, iter_end - iter_beg, 1000)
    x_limits <- c(0, iter_end - iter_beg)
    y_limits <- c(200, 1000)
} else if (opt$arg == 4) {
    iter_beg <- 150000
    iter_end <- 165000
    x_breaks <- seq(0, iter_end - iter_beg, 1000)
    x_limits <- c(0, iter_end - iter_beg)
    y_limits <- c(200, 1000)
}

output_dev(opt$type, opt$out, fig_width, fig_height)

read_data(opt$data) %>%
    filter(iter >= iter_beg) %>%
    filter(iter <= iter_end) %>%
    # mutate(iter = iter - iter_beg) %>%
    filter(cycles < 10000) %>%
    naplot(
        text = element_text(size = 22),
    plot.margin = margin(r = 10)
    ) +
        geom_step(
            aes(
                x = iter,
                y = cycles
            )
        ) +
        scale_x_continuous(
            # breaks = x_breaks,
            name = "Iter"
        ) +
        scale_y_continuous(
            name = "Latency (cycle)"
        ) +
        coord_cartesian(
            # xlim = x_limits,
            ylim = y_limits
        )
output_dev_close()

suppressPackageStartupMessages(library(optparse))
additional_option_list = list(
    make_option(
        c("-a", "--arg"),
        type = "integer",
        help = "optional additional arg",
        metavar = "number"
    )
)
source("../script/figure/r/cmdline.R")
source("../script/figure/r/common.R")
suppressPackageStartupMessages(library(jsonlite))

df <- read_data(opt$data)

signal_type <- opt$arg
pal_fix <- c()
pal_fix[1] <- pal_jama()(3)[opt$arg]

x_breaks <- seq(0, 64, 8)

output_dev(opt$type, opt$out, fig_full_width, 1.2 * fig_full_height)
naplot(
    data = df,
    text = element_text(size = 22),
    legend.position = "none"
) +
    geom_step(
        aes(x = iter, y = long_lat, color = "pmem"),
        size = line_default_size
    ) +
    scale_x_continuous(name = "Iter", breaks = x_breaks) +
    scale_y_continuous(name = "\\# of Long Latencies", limits = c(0, 30)) +
    scale_color_manual(name = "", values = pal_fix)
output_dev_close()

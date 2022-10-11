suppressPackageStartupMessages(library(optparse))
additional_option_list <- list(
    make_option(
        c("-c", "--threshold_cycle"),
        type = "integer",
        help = "Threshold cycle",
        metavar = "number"
    )
)
source("../script/figure/r/cmdline.R")
source("../script/figure/r/common.R")
suppressPackageStartupMessages(library(plotly))

df <- fromJSON(opt$data) %>%
    filter(threshold_cycle == opt$threshold_cycle) %>%
    filter(log2(access_size) %% 1 == 0) %>%
    filter(access_size >= 256)

output_dev(opt$type, opt$out, 0.8 * fig_full_width, 0.6 * fig_full_height)

naplot(
    data = df,
    legend.position = "none"
) +
    scale_fill_carto_d(palette = "Antique") +
    geom_boxplot(
        aes(
            x = factor(access_size),
            y = iter,
            fill = factor(access_size)
        )
    ) +
    scale_x_discrete(name = "Region Size (Byte)") +
    scale_y_continuous(
        name = "Write Iters",
        trans = "log2",
        limits = c(1024, 65536),
        breaks = c(1024, 4096, 16384, 65536)
    )

output_dev_close()

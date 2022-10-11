suppressPackageStartupMessages(library(optparse))
additional_option_list = list(
    make_option(
        c("-a", "--arg"),
        type = "integer",
        help = "optional additional arg",
        metavar = "number"
    )
)
source('../script/figure/r/cmdline.R')
source('../script/figure/r/common.R')
suppressPackageStartupMessages(library(jsonlite))

df <- fromJSON(opt$data) %>%
    as.data.frame

signal_type <- opt$arg
x_breaks <- seq(0, 128, 16)

output_dev(opt$type, opt$out, fig_full_width, fig_full_height)
if (signal_type == 1) {
    naplot(
        data = df,
        text = element_text(size = 20),
        legend.position = 'none'
    ) +
        geom_step(aes(x = result.threads.1.iter_summary.iter-32, y = result.threads.1.iter_summary.lat_ld$median / (task.region_size / task.block_size), color = 'sender'), size = line_default_size) +
        scale_x_continuous(name = "Iter", breaks = x_breaks) +
        scale_y_continuous(name = "Avg. Lat. (cycle)")
} else if (signal_type == 2) {
    print(df$result.summary.latency_threshold.lat_ld[1])

    pal_origin <- pal_jama()(3)
    pal_fix <- c()
    pal_fix[1] <- pal_origin[2]


    naplot(
        data = df,
        text = element_text(size = 20),
        legend.position = 'none'
    ) +
        geom_step(aes(x = result.threads.2.iter_summary.iter-32, y = result.threads.2.iter_summary.lat_ld$median / (task.region_size / task.block_size), color = 'receiver'), size = line_default_size) +
        scale_color_manual(name = '', values=pal_fix) +
        scale_x_continuous(name = "Iter", breaks = x_breaks) +
        scale_y_continuous(name = "Avg. Lat. (cycle)")
}
output_dev_close()

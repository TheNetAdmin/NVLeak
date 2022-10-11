source("../script/figure/r/cmdline.R")
source("../script/figure/r/common.R")

df <- fromJSON(opt$data, flatten = TRUE) %>%
    as.data.frame()

output_dev(opt$type, opt$out, fig_half_width, fig_half_height)
df %>%
    filter(delay <= 524288) %>%
    filter(delay_per_byte %in% c(256, 1024, 4096, 8192)) %>%
    naplot(
        legend.text = element_text(size = 9),
        legend.position = c(0.33, 0.33)
    ) +
    geom_line(
        aes(
            x = delay,
            y = cycle_99_99_percentile / (2.2 * 1000),
            color = factor(delay_per_byte)
        ),
        size = line_default_size
    ) +
    scale_x_continuous(
        name = "Delay Duration (Cycle)",
        trans = "log2",
        labels = byte_scale,
        breaks = c(256, 2 * 1024, 32 * 1024, 512 * 1024, 8 * 1024 * 1024)
    ) +
    scale_y_continuous(
        name = "P99.99 Latency (us)",
        limits = c(0, 60),
        breaks = c(0, 15, 30, 45, 60)
    ) +
    scale_color_jama(
        name = "Inject Interval (Byte)", labels = byte_scale_factor
    ) +
    guides(color = guide_legend(nrow = 2)) +
    theme(
        legend.background = element_blank()
    )
output_dev_close()

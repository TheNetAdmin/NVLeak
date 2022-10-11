source("../script/figure/r/cmdline.R")
source("../script/figure/r/common.R")


df <- fromJSON(opt$data, flatten = TRUE) %>%
    as.data.frame

output_dev(opt$type, opt$out, fig_half_width, fig_full_height)
df %>%
    filter(log2(delay_per_byte) %% 1 == 0) %>%
    naplot(
        panel.grid.major.y = element_line(
            linetype = "solid",
            size = vline_default_size / 2,
            color = "gray85"
        ),
        panel.grid.minor.y = NULL,
        panel.grid.major.x = NULL,
        text = element_text(size = 8),
        legend.text = element_text(size = 8),
        legend.key.height = unit(0.25, "cm")
    ) +
    geom_point(
        aes(
            x = delay_per_byte,
            y = delay,
            color = cycle_99_99_percentile / (2.2 * 1000)
        ),
        size = 1,
        alpha = 0.75
    ) +
    scale_x_continuous(
        name = "Injection Interval (Byte)",
        trans = "log2",
        labels = byte_scale,
        breaks = c(256, 2 * 1024, 32 * 1024, 512 * 1024)
    ) +
    scale_y_continuous(
        name = "Delay Duration (Cycle)",
        trans = "log2",
        labels = byte_scale,
        breaks = c(256, 2 * 1024, 32 * 1024, 512 * 1024, 8 * 1024 * 1024)
    ) +
    scale_color_viridis_c(
        option = "A",
        name = "P99.99 Latency (us)",
        breaks = c(0, 15, 30, 45, 60), direction = -1
    ) +
    theme(legend.position = "top")
output_dev_close()

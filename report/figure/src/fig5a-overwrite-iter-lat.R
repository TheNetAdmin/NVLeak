source("../script/figure/r/cmdline.R")
source("../script/figure/r/common.R")

df <- read_data(opt$data)
df <- df %>%
    mutate(lat_us = (lat * (1 / 2.2)) / 1000) %>%
    filter(iter <= 150 * 1000)

output_dev(opt$type, opt$out, fig_half_width, fig_half_height)
df %>%
    naplot(
        legend.position = "none"
    ) +
    geom_line(
        data = df,
        aes(x = iter, y = lat_us, color = factor(0)),
        size = line_default_size
    ) +
    scale_x_continuous(
        name = "Access iteration",
        labels = format_si()
    ) +
    scale_y_continuous(
        name = "Latency (us)",
        trans = "log10",
        limits = c(0.2, 100),
        breaks = c(0.2, 1, 10, 60),
        expand = c(0.005, 0)
    )
output_dev_close()

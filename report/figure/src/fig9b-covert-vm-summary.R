source('../script/figure/r/cmdline.R')
source('../script/figure/r/common.R')
suppressPackageStartupMessages(library(jsonlite))

df <- fromJSON(opt$data) %>%
    as.data.frame

output_dev(opt$type, opt$out, fig_half_width, fig_full_height)
df %>%
naplot(
    legend.position='none',
    panel.grid.major.y = element_line(linetype = "solid", size=0.5 * vline_default_size, color="gray85"),
    panel.grid.minor.y = element_line(linetype = "solid", size=0.5 * vline_default_size, color="gray85"),
    panel.grid.major.x = element_line(linetype = "solid", size=0.5 * vline_default_size, color="gray85"),
    text = element_text(size=8)
) +
    geom_point(aes(result$summary$metric$median$recv_data$lat_sl$error_rate * 100, result$summary$bit_rate$receiver), size=1.25, alpha=0.35) +
    scale_x_continuous(name = "Receiver Error Rate (%)", breaks = seq(0, 100, 10)) +
    scale_y_continuous(name = "Receiver Bit Rate (bps)", trans = "log10", labels=bitrate_scale, breaks=c(1000, 10 * 1000, 100 * 1000))
output_dev_close()

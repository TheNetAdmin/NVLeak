source("../script/figure/r/cmdline.R")
source("../script/figure/r/common.R")

df <- read_data(opt$data)
df <- df[df$block_size == 64, ]
df <- df[df$region_size <= 512 * 1024 * 1024, ]

# df$ld_lat <- 0
# df$st_lat <- 0
# df$delta_ld_lat <- 0
# df$delta_st_lat <- 0

# for (i in 1:nrow(df)) {
#     d <- df[i, ]

#     base_ld_lat <- (d$cycle_read_end - d$cycle_write_end) / d$count / d$access_size * 64
#     df[i, ]$ld_lat <- base_ld_lat

#     base_st_lat <- (d$cycle_write_end - d$cycle_start) / d$count / d$access_size * 64
#     df[i, ]$st_lat <- base_st_lat
# }

# mean(df[["delta_ld_lat"]])
# mean(df[["delta_st_lat"]])

output_dev(opt$type, opt$out, fig_half_width, fig_half_height)

df %>%
naplot(
    legend.position = c(0.5, 0.995),
    legend.background = element_blank()
) +
    geom_line(
        aes(
            x = region_size,
            y = (cycle_read_start - cycle_write_start) / count / region_size * 64,
            color = "st"
        ),
        size = line_default_size
    ) +
    geom_line(
        aes(
            x = region_size,
            y = (cycle_read_end - cycle_read_start) / count / region_size * 64,
            color = "ld"
        ),
        size = line_default_size
    ) +
    scale_y_continuous(
        name = "Latency (cycle)",
        limits = c(0, 1000),
        expand = c(0.005, 0)
    ) +
    scale_x_continuous(
        name = "PC-Region size (byte)",
        trans = "log2",
        labels = byte_scale,
        breaks = c(
            64,
            512,
            16 * 1024,
            1 * 1024 * 1024,
            16 * 1024 * 1024,
            256 * 1024 * 1024
        )
    ) +
    guides(
        color = guide_legend(nrow = 1)
    )
output_dev_close()

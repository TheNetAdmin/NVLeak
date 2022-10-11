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
suppressPackageStartupMessages(library(plotly))

if (opt$arg == 0) {
    df <- read_data(opt$data)
} else {
    df <-  fromJSON(opt$data, flatten = TRUE) %>%
        as.data.frame %>%
        filter(result.total_pc_blocks > 1)
}

p <- naplot(
    data = df,
    legend.position = "top",
    panel.grid.major.y = NULL,
    panel.grid.minor.y = NULL,
    panel.grid.major.x = NULL,
    panel.grid.minor.x = NULL
)

if (opt$arg == 0) {
    p <- p +
        geom_tile(
            aes(
                x = stride_size,
                y = total_pc_blocks,
                fill = ld_lat_per_cl
            )
        )
} else {
    p <- p +
        geom_tile(
            aes(
                x = result.stride_size,
                y = result.total_pc_blocks,
                fill = result.ld_lat_per_cl
            )
        )
}

p <- p +
    scale_fill_viridis(
        name = "Lat (Cycle)",
        option = "cividis"
    ) +
    scale_y_continuous(
        name = "# of PC-Blocks",
        trans = "log2",
        labels = byte_scale,
        breaks = c(
            1,
            4,
            16,
            64,
            256,
            1024,
            4096,
            16384
        )
    ) +
    scale_x_continuous(
        name = "Stride Size (Byte)",
        trans = "log2",
        labels = byte_scale,
        breaks = c(
            256,
            4 * 1024,
            64 * 1024,
            1 * 1024 * 1024,
            16 * 1024 * 1024
        )
    )

gp <- ggplotly(p)
save_image(gp, opt$out, height = 0.6 * fig_half_height_pixel)

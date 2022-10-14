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

df <- read_data(opt$data) %>%
      mutate(set_addr_idx = page_idx %/% 256) %>%
      mutate(set_idx = page_idx %% 256)

if (opt$arg == 0) {
    data_pos <- data.frame(
        xmin      = 1052,
        xmax      = 1068,
        ymin      =    0,
        ymax      =   12,
        ymin_data =    3,
        ymax_data =    7
    )
    zoom_pos <- data.frame(
        xmin = 500,
        xmax = 500 + 500 * 1.5,
        ymin =  64,
        ymax =  64 +  64 * 1.8
    )
    zoom_x_axis_breaks <- c(1052, 1060, 1068)
} else if (opt$arg == 1) {
    data_pos <- data.frame(
        xmin      = 32,
        xmax      = 48,
        ymin      =  0,
        ymax      = 12,
        ymin_data =  3,
        ymax_data =  7
    )
    zoom_pos <- data.frame(
        xmin =   0,
        xmax =   0 + 500 * 1.5,
        ymin = 128,
        ymax = 128 + 64 * 1.8
    )
    zoom_x_axis_breaks <- c(32, 40, 48)
}

p_origin <- df %>%
    naplot(
    ) +
    # scale_fill_viridis() +
    # scale_color_viridis() +
    geom_point(
        aes(
            x = key,
            y = set_idx
        ),
        size = 1
    )

p_base <- p_origin +
    theme(
        text = element_text(size = 20)
    ) +
    labs(
        x = "Key",
        y = "NVCache Set Index"
    ) +
    scale_y_continuous(
        breaks = c(0, 64, 128, 192, 256),
        limits = c(0, 256)
    ) +
    geom_rect(
        data = data_pos,
        aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
        color = "black",
        alpha = 0
    )

p_zoom <- p_origin +
    theme(
        text = element_text(size = 11)
    ) +
    scale_x_continuous(
        breaks = zoom_x_axis_breaks,
        name = element_blank(),
        limits = c(data_pos$xmin     , data_pos$xmax     )
    ) +
    scale_y_continuous(
        name = element_blank(),
        limits = c(data_pos$ymin_data, data_pos$ymax_data)
    )

if (opt$arg == 0) {
    p_zoom <- p_zoom +
        theme(
            plot.margin = margin(t = 2, r = 10, b = 2, l = 2, "pt")
        )
}

p <- p_base +
    annotation_custom(
        ggplotGrob(p_zoom),
        xmin = zoom_pos$xmin,
        xmax = zoom_pos$xmax,
        ymin = zoom_pos$ymin,
        ymax = zoom_pos$ymax
    ) +
    geom_rect(
        data = zoom_pos,
        aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
        color = "black",
        alpha = 0,
        linetype = "dashed"
    ) +
    geom_path(
        data = data.frame(
            x = c(
                data_pos$xmin,
                zoom_pos$xmin,
                data_pos$xmax,
                zoom_pos$xmax
            ),
            y = c(
                data_pos$ymax,
                zoom_pos$ymin,
                data_pos$ymax,
                zoom_pos$ymin
            ),
            grp = c(
                1,
                1,
                2,
                2
            )
        ),
        aes(x, y, group = grp),
        linetype = "dashed"
    )

output_dev(opt$type, opt$out, 0.75 * fig_full_width, 0.6 * fig_full_width)

p

output_dev_close()

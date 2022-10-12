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

df <- read_data(opt$data)

threshold_type <- opt$arg

# iter_beg/iter_end: the begin/end of displayed range, including non-feature parts
# con_beg/con_end: the begin/end of the actual features, for latency distribution
if (threshold_type == 1) {
    # AEP1: U1
    iter_beg <- 515
    iter_end <- 615
    set_beg <- 0
    set_end <- 128
    con_beg <- 568
    con_end <- 570
    x_breaks <- c(0, 25, 50, 75, 100)
    df <- df %>%
        filter(lat >= 900) %>%
        filter(lat <= 1200)
} else if (threshold_type == 2) {
    # AEP1: U2
    iter_beg <- 760
    iter_end <- 860
    set_beg <- 0
    set_end <- 128
    con_beg <- 777
    con_end <- 848
    x_breaks <- c(0, 25, 50, 75, 100)
    df <- df %>%
        filter(lat >= 900) %>%
        filter(lat <= 1200)
} else if (threshold_type == 3) {
    # AEP1: C1
    iter_beg <- 100
    iter_end <- 400
    set_beg <- 0
    set_end <- 128
    con_beg <- 163
    con_end <- 363
    x_breaks <- c(0, 100, 200, 300)
    df <- df %>%
        filter(frac_median >= 1.02) %>%
        filter(frac_median <= 1.10)
} else if (threshold_type == 4) {
    # AEP1: Q1
    iter_beg <- 100
    iter_end <- 400
    set_beg <- 0
    set_end <- 128
    con_beg <- 167
    con_end <- 257
    x_breaks <- c(0, 100, 200, 300)
    df <- df %>%
        filter(frac_median >= 1.02) %>%
        filter(frac_median <= 1.10)
} else if (threshold_type == 5) {
    # AEP1: I1
    iter_beg <- 300
    iter_end <- 400
    set_beg <- 128
    set_end <- 256
    con_beg <- 568
    con_end <- 570
    x_breaks <- c(0, 25, 50, 75, 100)
    df <- df %>%
        filter(lat >= 900) %>%
        filter(lat <= 1200)
} else if (threshold_type == 6) {
    # NV-4: S1
    iter_beg <- 210
    iter_end <- 310
    set_beg <- 0
    set_end <- 128
    con_beg <- 216
    con_end <- 300
    x_breaks <- c(0, 25, 50, 75, 100)
    df <- df %>%
        filter(lat >= 900) %>%
        filter(lat <= 1200)
} else if (threshold_type == 7) {
    # NV-4: C2
    iter_beg <- 750
    iter_end <- 900
    set_beg <- 0
    set_end <- 128
    con_beg <- 763
    con_end <- 886
    x_breaks <- c(0, 50, 100, 150)
    df <- df %>%
        filter(lat >= 900) %>%
        filter(lat <= 1300)
} else if (threshold_type == 8) {
    # NV-4: C3
    iter_beg <- 1020
    iter_end <- 1220
    set_beg <- 0
    set_end <- 128
    con_beg <- 1028
    con_end <- 1216
    x_breaks <- c(0, 50, 100, 150, 200)
    df <- df %>%
        filter(lat >= 900) %>%
        filter(lat <= 1300)
} else {
    print("Unknown threshold_type")
    quit(status = 1)
}

plot_concentrated <- function(df, iter_beg, iter_end, set_beg, set_end, con_beg, con_end, x_breaks) {
    p1 <- df %>%
        filter(iter >= con_beg) %>%
        filter(iter <= con_end) %>%
        mutate(lat_round = plyr::round_any(lat, 2.5)) %>%
        naplot(
            axis.text.y = element_blank(),
            axis.ticks.y = element_blank(),
            panel.grid.minor.y = NULL,
            plot.margin = margin(t = 5, l = 22, b = 10, r = 14),
            text = element_text(size = 15)
        ) +
        scale_fill_viridis() +
        scale_color_viridis() +
        geom_histogram(aes(x = lat_round, y = ..density..), colour = "black", fill = factor(5), alpha = .8) +
        geom_density(aes(x = lat_round), fill = factor(3), alpha = .4) +
        scale_x_continuous(limits = c(800, 1200), breaks = c(800, 1000, 1200)) +
        scale_y_continuous(limits = c(0, 0.06)) +
        labs(x = "Latency", y = "Density")

    p2 <- df %>%
        filter(iter >= iter_beg) %>%
        filter(iter <= iter_end) %>%
        filter(set >= set_beg) %>%
        filter(set <= set_end) %>%
        naplot(
            legend.position = "none",
            plot.margin = margin(r = 14),
            text = element_text(size = 15)
        ) +
        geom_point(aes(x = iter - iter_beg, y = set - set_beg, fill = factor(0)), size = 1) +
        scale_y_continuous(breaks = seq(0, (set_end - set_beg), 16)) +
        scale_x_continuous(breaks = x_breaks, limits = c(0, iter_end-iter_beg)) +
        labs(x = "Iter.", y = "L2 NVCache Set")

    grid.arrange(p1, p2, ncol = 1, heights = c(1, 3))
}

output_dev(opt$type, opt$out, fig_full_height, fig_full_width)
df %>% plot_concentrated(iter_beg, iter_end, set_beg, set_end, con_beg, con_end, x_breaks)
output_dev_close()

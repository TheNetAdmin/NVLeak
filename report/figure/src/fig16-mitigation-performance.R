source("../script/figure/r/cmdline.R")
source("../script/figure/r/common.R")
suppressPackageStartupMessages(library(psych))
suppressPackageStartupMessages(library(tidyverse))

df <- read_data(opt$data)

d <- df %>% filter(version == "original")
gmean_orig <- geometric.mean(d$norm_time)

d <- df %>% filter(version == "mitigation")
gmean_mitg <- geometric.mean(d$norm_time)

print(gmean_mitg)

df <- df %>%
    add_row(abbr = "gmean", version = "original", norm_time = gmean_orig) %>%
    add_row(abbr = "gmean", version = "mitigation", norm_time = gmean_mitg)

output_dev(opt$type, opt$out, fig_full_width, fig_half_height)

df %>%
mutate(
    version = factor(version, levels = c("original", "mitigation"))
) %>%
mutate(
    abbr = factor(
        abbr,
        levels = c(
            "app",
            "spp",
            "asrp",
            "ssrp",
            "rti",
            "rtr",
            "rts",
            "rtsn",
            "chmi",
            "gmean"
        )
    )
) %>%
naplot(
    axis.text.x = element_text(size = 14),
    legend.key.size = unit(10, "pt"),
    legend.position = c(0.5, 0.94)
) +
    scale_fill_carto_d(palette = "Antique") +
    geom_bar(
        aes(x = abbr, y = norm_time, fill = version),
        colour = "black",
        stat = "identity",
        position = position_dodge(width = 0.8),
        width = 0.78,
        size = 0.2
    ) +
    labs(
        x = "Benchmark",
        y = "Norm. Run Time",
        fill = element_blank()
    ) +
    scale_y_continuous(
        limits = c(0, 1.4),
        breaks = c(0, 0.5, 1.0, 1.5),
        expand = expansion(mult = c(0, .1))
    ) +
    guides(
        fill = guide_legend(nrow = 1)
    )

output_dev_close()

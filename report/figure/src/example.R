source('../script/figure/r/cmdline.R')
source('../script/figure/r/common.R')

df <- read_data(opt$data)

output_dev(opt$type, opt$out, fig_full_width, fig_full_height)
    naplot(
        data = df
    ) +
        geom_line(
            aes(x = key, y = val, color = "example"),
            size = line_default_size
        ) +
        scale_x_continuous(name = "Key") +
        scale_y_continuous(name = "Val")
output_dev_close()

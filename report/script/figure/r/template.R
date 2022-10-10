source("../script/figure/r/cmdline.R")
source("../script/figure/r/common.R")

output_dev(opt$type, opt$out, fig_half_width, fig_half_height)

read_data(opt$data) %>%
    naplot() +

output_dev_close()

## Plot a geom_line
## geom_line(data = df, aes(x = , y = , color = ), size=line_default_size)

## Plot a geom_bar
## geom_bar(data = , aes(x = , y = , fill = ), colour='black', stat='identity', position=position_dodge(width=0.8), width=0.78, size=0.2)

## Reorder factorized legends
## df$col <- factor(df$col, levels=c())

## Reorder factorized data frame col
## mutate(
##    module = factor(module, levels=c("val1", "val2", "val3"))
## ) %>%

## Scale x axis with byte labels
## scale_x_continuous(name = '', trans = 'log2', labels = byte_scale)

## Remove axis title and white spaces
## scale_x_continuous(name = NULL)

## Expand y axis to full plot
## scale_y_continuous(expand = c(0.005, 0))

## Remove minor y axis line
## panel.grid.minor.y = NULL

## Change axis name
## labs(x = "", y = "", title="")

## Change legend style
## https://r-graph-gallery.com/239-custom-layout-legend-ggplot2.html

## Save ggplotly
## gp <- ggplotly(p)
## save_image(gp, opt$out, width = fig_half_width_pixel, height = fig_half_height_pixel)

## Add additional command line options, add following lines before any other 'source()'
## suppressPackageStartupMessages(library(optparse))
## additional_option_list = list(
##     make_option(
##         c("-a", "--arg"),
##         type = "integer",
##         help = "optional additional arg",
##         metavar = "number"
##     )
## )

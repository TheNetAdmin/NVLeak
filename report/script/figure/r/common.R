suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(ggpubr))
suppressPackageStartupMessages(library(ggsci))
suppressPackageStartupMessages(library(tikzDevice))
suppressPackageStartupMessages(library(scales))
suppressPackageStartupMessages(library(ggrepel))
suppressPackageStartupMessages(library(viridis))
suppressPackageStartupMessages(library(grid))
suppressPackageStartupMessages(library(gridExtra))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(jsonlite))
suppressPackageStartupMessages(library(rcartocolor))
suppressPackageStartupMessages(library(grDevices))

line_default_size <- 1.25
vline_default_size <- 0.75
bar_outline_default_size <- 0.5
grid_line_default_size <- 1

naplot <- function(data, color_name = "", fill_name = "", ...) {
    return(
        data %>%
            ggplot() +
            theme_pubr(border = TRUE, base_family = "sans") +
            scale_color_jama(name = color_name) +
            scale_fill_jama(name = fill_name) +
            theme(
                text = element_text(size = 11),
                legend.position = "top",
                legend.margin = margin(0, 0, -10, 0),
                legend.text = element_text(size = 10),
                axis.ticks.length = unit(0.05, "cm"),
                axis.text.x = element_text(margin = margin(5, 0, 0, 0, "pt")),
                axis.text.y = element_text(margin = margin(0, 5, 0, 0, "pt")),
                panel.border = element_rect(size = 1.5),
                panel.grid.major.y = element_line(
                    linetype = "dotted",
                    size = grid_line_default_size,
                    color = "gray85"
                ),
                panel.grid.major.x = element_line(
                    linetype = "dotted",
                    size = grid_line_default_size,
                    color = "gray85"
                )
            ) %+replace%
            theme(...)
    )
}

read_data <- function(filename) {
    return(read.csv(filename, strip.white = TRUE))
}

fig_full_width <- 6.60
fig_full_height <- 2.69

fig_half_width <- 3.20
fig_half_height <- 1.80

fig_trd_width <- 2.10
fig_trd_height <- 1.20

fig_quad_width <- 1.60
fig_quad_height <- 0.90

# Under 300 PPI
fig_half_width_pixel <- 960
fig_half_height_pixel <- 540

pub_ppi <- 600

output_dev <- function(type, out_filename, out_width, out_height) {
    if (type == "tikz") {
        tikz(file = out_filename, width = out_width, height = out_height, documentDeclaration = "documentclass[10pt]{article}")
    } else if (type == "pdf") {
        cairo_pdf(
            filename = out_filename,
            width = out_width,
            height = out_height,
            # pointsize = 1 / pub_ppi,
            onefile = TRUE,
            family = "sans"
        )
    } else if (type == "png") {
        png(file = out_filename, width = out_width, height = out_height, units = "in", res = 120)
    }
}

output_dev_close <- function() {
    supress <- dev.off()
}

output_file <- function(type, out_filename, out_width, out_height) {
    if (type == "tikz") {
        ggsave(file = out_filename, width = out_width, height = out_height, device = tikzDevice::tikz)
    } else if (type == "pdf") {
        ggsave(file = out_filename, width = out_width, height = out_height, pointsize = 1 / pub_ppi, device = "pdf")
    }
}

# Comes from "scales::byte_number_format"
byte_scale <- function(number, unit = "") {
    sifactor <- c(1, 1024, 1024^2, 1024^3, 1024^4, 1024^5, 1024^6, 1024^7, 1024^8)
    pre <- c("", " K", " M", " G", " T", " P", " E", " Z", " Y")
    absolutenumber <- number * sign(number)
    ix <- findInterval(absolutenumber, sifactor)
    if (length(ix) > 0) {
        sistring <- paste(number / sifactor[ix], pre[ix], sep = "", unit = unit)
    } else {
        sistring <- as.character(number)
    }
    return(sistring)
}

byte_scale_factor <- function(number, unit = "") {
    sifactor <- c(1, 1024, 1024^2, 1024^3, 1024^4, 1024^5, 1024^6, 1024^7, 1024^8)
    pre <- c("", " K", " M", " G", " T", " P", " E", " Z", " Y")
    number <- as.numeric(as.character(number))
    absolutenumber <- number * sign(number)
    ix <- findInterval(absolutenumber, sifactor)
    if (length(ix) > 0) {
        sistring <- paste(number / sifactor[ix], pre[ix], sep = "", unit = unit)
    } else {
        sistring <- as.character(number)
    }
    return(sistring)
}

bitrate_scale <- function(number, unit = "") {
    sifactor <- c(1, 1000, 1000^2, 1000^3, 1000^4, 1000^5, 1000^6, 1000^7, 1000^8)
    pre <- c("", " K", " M", " G", " T", " P", " E", " Z", " Y")
    absolutenumber <- number * sign(number)
    ix <- findInterval(absolutenumber, sifactor)
    if (length(ix) > 0) {
        sistring <- paste(sprintf("%.0f", number / sifactor[ix]), pre[ix], sep = "", unit = unit)
    } else {
        sistring <- as.character(number)
    }
    return(sistring)
}

format_si <- function(...) {
    # Based on code by Ben Tupper
    # https://stat.ethz.ch/pipermail/r-help/2012-January/299804.html

    function(x) {
        limits <- c(
            1e-24, 1e-21, 1e-18, 1e-15, 1e-12,
            1e-9, 1e-6, 1e-3, 1e0, 1e3,
            1e6, 1e9, 1e12, 1e15, 1e18,
            1e21, 1e24
        )
        prefix <- c(
            "y", "z", "a", "f", "p",
            "n", "µ", "m", " ", "k",
            "M", "G", "T", "P", "E",
            "Z", "Y"
        )

        # Vector with array indices according to position in intervals
        i <- findInterval(abs(x), limits)

        # Set prefix to " " for very small values < 1e-24
        i <- ifelse(i == 0, which(limits == 1e0), i)

        paste(
            format(round(x / limits[i], 1),
                trim = TRUE, scientific = FALSE, ...
            ),
            prefix[i]
        )
    }
}

vline <- function(xint) {
    return(geom_vline(xintercept = xint, color = "gray65", linetype = "solid", size = vline_default_size))
}
hline <- function(xint) {
    return(geom_hline(yintercept = xint, color = "gray65", linetype = "solid", size = vline_default_size))
}
vline_dashed <- function(xint) {
    return(geom_vline(xintercept = xint, color = "gray65", linetype = "longdash", size = vline_default_size))
}
vline_toppicks <- function(xint) {
    return(geom_vline(xintercept = xint, color = "gray50", linetype = "solid", size = vline_default_size))
}


na_text_repel <- function(label_points) {
    return(
        geom_text_repel(
            data = label_points,
            aes(x, y, label = pos),
            arrow = NULL,
            direction = "x",
            angle = 90,
            nudge_y = 0,
            hjust = 0,
            size = 3
        )
    )
}

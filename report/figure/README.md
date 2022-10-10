# Plots

Available options:
  - code   (source code file name under figure/src without leading path)
  - data   (data file name under data/ without leading path)
  - type   (multiple options are separated with colon)
    1. pdf      : source code -> pdf
    2. tikz     : source code -> tikz
    3. tikz_pdf : source code -> tikz -> pdf
    4. tikz_svg : source code -> tikz -> pdf -> svg
  - tikz_post_process (script name under script/figure/tikz_post_process):
    1. heatmap_path_fix.sh

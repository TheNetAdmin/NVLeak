FROM texlive/texlive:latest

RUN apt-get update && \
    apt-get install -qy --no-install-recommends r-base cmake build-essential poppler-utils g++ python3-pip ghostscript gfortran libblas-dev liblapack-dev libpng-dev && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/ && \
    Rscript -e 'install.packages(c("optparse", "ggplot2", "ggpubr", "ggsci", "tikzDevice", "scales", "ggrepel", "viridis", "gridExtra", "dplyr", "jsonlite", "rcartocolor"))'

RUN pip3 install pandas click fuzzywuzzy prettytable BeautifulSoup4

WORKDIR /nap

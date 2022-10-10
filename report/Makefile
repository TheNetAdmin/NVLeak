.DEFAULT_GOAL:=paper
make_flag:=--no-print-directory -j8

.PHONY: paper
paper:	paper.pdf


paper.pdf: figure
	latexmk -shell-escape -pdf -synctex=1 paper.tex
	pdffonts paper.pdf > paper.pdf.font.log


.PHONY: grammar
grammar:
	bash script/text_process/pandoc_latex_to_plain.sh paper.tex paper.txt


.PHONY: grayscale
grayscale: paper.grayscale.pdf


paper.grayscale.pdf: paper.pdf
	gs \
	-sOutputFile=$@ \
	-sDEVICE=pdfwrite \
	-sColorConversionStrategy=Gray \
	-dProcessColorModel=/DeviceGray \
	-dCompatibilityLevel=1.4 \
	-dAutoRotatePages=/None \
	-dEmbedAllFonts=true \
	-dNOPAUSE \
	-dBATCH \
	$<


.PHONY: docker-build
docker-build:
	bash script/docker/run.sh make paper.pdf


figure/Makefile: figure/plots.csv \
                 script/figure/configure.py
	@echo GEN $@
	@python script/figure/configure.py gen-makefile $< $@


figure/plots.tex: figure/plots.csv \
                  script/figure/configure.py
	@echo GEN $@
	@python script/figure/configure.py gen-texfile $< $@


.PHONY: figure
figure: figure/Makefile figure/plots.tex
	@make ${make_flag} -C figure all_tikz_pdf all_pdf


.PHONY: clean
clean:
	@latexmk -c


.PHONY: clean_all
clean_all: clean
	@make ${make_flag} -C figure clean

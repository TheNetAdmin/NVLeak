PAPER = asplos22-paper-template
ABSTRACT = asplos22-extended-abstract-template
TEX = $(wildcard *.tex)
BIB = references.bib
FIGS = $(wildcard figures/*.pdf figures/*.png graphs/*.pdf graphs/*.png)

.PHONY: all clean

all: $(PAPER).pdf $(ABSTRACT).pdf

$(PAPER).pdf: $(TEX) $(BIB) $(FIGS) jpaper.cls
	echo $(FIGS)
	pdflatex $(PAPER)
	bibtex $(PAPER)
	pdflatex $(PAPER)
	pdflatex $(PAPER)

$(ABSTRACT).pdf: $(TEX) $(BIB) $(FIGS) jpaper.cls
	pdflatex $(ABSTRACT)
	bibtex $(ABSTRACT)
	bibtex $(ABSTRACT)
	pdflatex $(ABSTRACT)
	pdflatex $(ABSTRACT)


clean:
	rm -f *.aux *.bbl *.blg *.log *.out $(PAPER).pdf $(ABSTRACT).pdf


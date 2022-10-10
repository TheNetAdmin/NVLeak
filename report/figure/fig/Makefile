
.DEFAULT_GOALS:=all

pdfs := # All pdfs under 'lucidchart' folder

curr_dir := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
gs_script := $(realpath $(curr_dir)/../../script/figure/ghostscript/embed_font.sh)

.PHONY: all
all: $(pdfs)

%.pdf: lucidchart/%.pdf
	bash $(gs_script) "$<" "$@"

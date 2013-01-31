all: pdf
pdf: build/kielhorn_memi.pdf
dvi: build/kielhorn_memi.dvi

MAINDOC = kielhorn_memi
MAINDOC_TEX=$(MAINDOC:%=%.tex)
MAINDOC_IN_BUILD=$(MAINDOC:%=build/%.tex)

CHAPTERS = spatio-angular
CHAPTERS_TEX=$(CHAPTERS:%=%.tex)
CHAPTERS_IN_BUILD=$(CHAPTERS:%=build/%.tex)

# the following sed command searches for occurances of \svginput{23.}{imagefile}
# and outputs imagefile
# the s command with option p ensures, that only matched patterns are printed
# [^\}]* denotes all characters except }, i have to use this because .* is greedy
# sed -n 's/^[^%].*\\svginput{[^\}]*}{\([^\}]*\)}/\1/p' *.tex

# use the sed command from above to find which images need to be processed
SVGFIGURES = $(shell sed -n 's/^[^%].*\\svginput{[^\}]*}{\([^\}]*\)}/\1/p' $(MAINDOC_TEX) $(CHAPTERS_TEX))
SVGFIGURES_SVG=$(SVGFIGURES:%=svg/%.svg)
SVGFIGURES_PDF=$(SVGFIGURES:%=build/%.pdf_tex)
SVGFIGURES_EPS=$(SVGFIGURES:%=build/%.eps_tex)

clean:
	rm build/*

# copy the tex files into the build directory, i do this to prevent
# cluttering my working directory with all the tex log files
build/%.tex: %.tex
	cp $*.tex build/$*.tex

# convert inkscape svg files into either eps or pdf files (there will
# be one image file and another file ending with .eps_tex that
# contains text overlay)
build/%.eps_tex: svg/%.svg
	inkscape $< --export-latex --export-eps=build/`basename $< .svg`.eps

build/%.pdf_tex: svg/%.svg
	inkscape $< --export-latex --export-pdf=build/`basename $< .svg`.pdf


# rubber runs the latex process until finished, --inplace makes sure
# that clutter stays in build/ directory
build/kielhorn_memi.pdf: $(MAINDOC_IN_BUILD) $(CHAPTERS_IN_BUILD) $(SVGFIGURES_PDF) $(SVGFIGURES_SVG)
	rubber --pdf --inplace $(MAINDOC_IN_BUILD)

build/kielhorn_memi.dvi: $(MAINDOC_IN_BUILD) $(CHAPTERS_IN_BUILD) $(SVGFIGURES_EPS) $(SVGFIGURES_SVG)
	rubber --inplace $(MAINDOC_IN_BUILD)

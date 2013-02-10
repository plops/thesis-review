all: pdf
pdf: build/kielhorn_memi.pdf
dvi: build/kielhorn_memi.dvi

MAINDOC = kielhorn_memi
MAINDOC_TEX=$(MAINDOC:%=%.tex)
MAINDOC_IN_BUILD=$(MAINDOC:%=build/%.tex)

CHAPTERS = spatio-angular device1
CHAPTERS_TEX=$(CHAPTERS:%=%.tex)
CHAPTERS_IN_BUILD=$(CHAPTERS:%=build/%.tex)

TEX_FILES = $(MAINDOC_TEX) $(CHAPTERS_TEX)


# the following sed command searches for occurances of \svginput{23.}{imagefile}
# and outputs imagefile
# the s command with option p ensures, that only matched patterns are printed
# [^\}]* denotes all characters except }, i have to use this because .* is greedy
# sed -n 's/^[^%].*\\svginput{[^\}]*}{\([^\}]*\)}/\1/p' *.tex

# use the sed command from above to find which images need to be processed

# damit ich nicht jedesmal beim make aufrufen sed aufrufen muss
# - sorgt dafuer das es keinen fehler gibt
-include build/make-pdf_tex.dep

# create a file with dependencies in the form
# file.tex: build/image1.pdf_tex build/image2.pdf_tex
# where image1 and image2 were included using \svginput in file.tex
build/make-pdf_tex.dep: $(TEX_FILES)
	for i in $^; do \
		echo -n build/$$i": "; \
		sed -n 's+^[^%].*\\svginput{[^\}]*}{\([^\}]*\)}+\1.pdf_tex+p' $$i|tr '\12' ' '; \
		echo ; \
	done > $@


# noch besser waere
#%.tex.dep: %.tex
#	grep something $< > $@


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

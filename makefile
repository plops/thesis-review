all: pdf
pdf: build/kielhorn_memi.pdf
dvi: build/kielhorn_memi.dvi

TEX_FILES_NOEXT = kielhorn_memi introduction spatio-angular device1
TEX_FILES = $(TEX_FILES_NOEXT:%=%.tex)
TEX_FILES_IN_BUILD=$(TEX_FILES:%=build/%)


# create a file with dependencies in the form
# file.tex: build/image1.pdf_tex build/image2.pdf_tex
# where image1 and image2 were included using \svginput in file.tex

# the sed command searches for occurances of \svginput{23.}{imagefile}
# and outputs imagefile
# the s command with option p ensures, that only matched patterns are
# printed [^\}]* denotes all characters except }, i have to use this
# because .* is greedy

# damit ich nicht jedesmal beim make aufrufen sed aufrufen muss
# - sorgt dafuer das es keinen fehler gibt
-include build/make.vector.pdf_tex.dep
build/make.vector.pdf_tex.dep: $(TEX_FILES)
	for i in $^; do \
		echo -n build/$$i": "; \
		sed -n 's+^[^%].*\\svginput{[^\}]*}{\([^\}]*\)}+build/\1.pdf_tex+p' $$i|tr '\12' ' '; \
		echo ; \
	done > $@
# convert inkscape svg files into either eps or pdf files (there will
# be one image file and another file ending with .eps_tex that
# contains text overlay)
build/%.pdf_tex: vector/%.svg
	inkscape $< --export-latex --export-pdf=build/`basename $< .svg`.pdf
build/%.eps_tex: vector/%.svg
	inkscape $< --export-latex --export-eps=build/`basename $< .svg`.eps


# find included pdf images, copy them to build/%.vector.pdf 
-include build/make.vector.pdf.dep
build/make.vector.pdf.dep: $(TEX_FILES)
	for i in $^; do \
		echo -n build/$$i": "; \
		sed -n 's+^[^%].*\\pdfinput{[^\}]*}{\([^\}]*\)}+build/\1.vector.pdf+p' $$i|tr '\12' ' '; \
		echo ; \
	done > $@
build/%.vector.pdf: vector/%.pdf
	cp $< $@

# find all included jpg files
-include build/make.raster.jpg.dep
build/make.raster.jpg.dep: $(TEX_FILES)
	for i in $^; do \
		echo -n build/$$i": "; \
		sed -n 's+^[^%]*\\jpginput{[^\}]*}{\([^\}]*\)}{.*+build/\1.jpg+p' $$i|tr '\12' ' '; \
		echo ; \
	done > $@
build/%.jpg: raster/%.jpg
	cp $< $@

# this would only run per file, but i don't know how to include the
# dependencies
#build/%.tex.svg-pdf_tex.dep: $(TEX_FILES)
#	sed -n 's+^[^%].*\\svginput{[^\}]*}{\([^\}]*\)}+\1.pdf_tex+p' $<|tr '\12' ' ' > $@


clean:
	rm build/*

# copy the tex files into the build directory, i do this to prevent
# cluttering my working directory with all the tex log files
build/%.tex: %.tex
	cp $< $@
build/%.bib: %.bib
	cp $< $@



# rubber runs the latex process until finished, --inplace makes sure
# that clutter stays in build/ directory
build/kielhorn_memi.pdf: $(TEX_FILES_IN_BUILD) build/literature.bib
	rubber --pdf --inplace $<

build/kielhorn_memi.dvi: $(TEX_FILES_IN_BUILD)
	rubber --inplace $<

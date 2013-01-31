all: build/kielhorn_memi.pdf


dvi: build/kielhorn_memi.dvi

latexfile = kielhorn_memi.tex

# the following sed command searches for occurances of \svginput{23.}{imagefile}
# and outputs imagefile
# the s command with option p ensures, that only matched patterns are printed
# [^\}]* denotes all characters except }, i have to use this because .* is greedy
# sed -n 's/^[^%].*\\svginput{[^\}]*}{\([^\}]*\)}/\1/p' *.tex

# use the sed command from above to find which images need to be processed
SVGFIGURES = objective-trace hourglass-all memi-simple
SVGFIGURES_PDF=$(SVGFIGURES:%=build/%.pdf_tex)
SVGFIGURES_EPS=$(SVGFIGURES:%=build/%.eps_tex)
CHAPTERS = spatio-angular
CHAPTERS_IN_BUILD=$(SVGFIGURES:%=build/%.tex)

build/%.tex: %.tex
	cp $*.tex build/$*.tex

# find all occurances of \svginput within the tex documents [^%]
# negative character class that ignores latex comments i need to write
# ($$_) instead of $_ (the perl expression for the lines from stdin),
# otherwise make will replace $_ with something
# perl -n acts on each line individually
define getsvg
        svgs=`perl -ne 'print (($$_) =~ /^[^%]*\\\svginput\{.*?\}\{(.*?)\}/g); print "\n"' $(chapters)`
endef 

echosvg:
	$(getsvg); echo $$svgs


build/%.eps_tex: svg/%.svg
	inkscape $< --export-latex --export-eps=build/`basename $< .svg`.eps

build/%.pdf_tex: svg/%.svg
	inkscape $< --export-latex --export-pdf=build/`basename $< .svg`.pdf


build/kielhorn_memi.pdf: build/$(latexfile) $(CHAPTERS_IN_BUILD) $(SVGFIGURES_PDF)
	rubber --pdf --inplace build/$(latexfile)

build/kielhorn_memi.dvi: build/$(latexfile) $(CHAPTERS_IN_BUILD) $(SVGFIGURES_EPS)
	rubber --inplace build/$(latexfile)

SOURCES = hallo welt
test:
	echo $(SVGFIGURES_EPS)

#$(getsvg)
#echo $($SVGFIGURES:%=obj/%.o)


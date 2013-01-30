all: build/kielhorn_memi.pdf


dvi: build/kielhorn_memi.dvi

latexfile = kielhorn_memi.tex

figures = frontmatter/objective-trace.svg

chapters = spatio-angular.tex

build/%.tex: %.tex
	cp $*.tex build/$*.tex

# find all occurances of \svginput within the tex documents [^%]
# negative character class that ignores latex comments i need to write
# ($$_) instead of $_ (the perl expression for the lines from stdin),
# otherwise make will replace $_ with something
define getsvg
        svgs=`perl -ne 'print (($$_) =~ /^[^%]*\\\svginput\{.*?\}\{(.*?)\}/g); print "\n"' $(chapters)`
endef 

echosvg:
	$(getsvg); echo $$svgs


build/%.eps_tex: svg/%.svg
	inkscape $< --export-latex --export-eps=build/`basename $< .svg`.eps

build/%.pdf_tex: svg/%.svg
	inkscape $< --export-latex --export-pdf=build/`basename $< .svg`.pdf

build/kielhorn_memi.pdf: build/$(latexfile) build/$(chapters) build/objective-trace.pdf_tex build/hourglass-all.pdf_tex build/memi-simple.pdf_tex
	rubber --pdf --inplace build/$(latexfile)

build/kielhorn_memi.dvi: build/$(latexfile) build/$(chapters) build/objective-trace.eps_tex build/hourglass-all.eps_tex build/memi-simple.eps_tex
	rubber --inplace build/$(latexfile)


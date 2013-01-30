all: build/kielhorn_memi.pdf


dvi: build/kielhorn_memi.dvi

latexfile = kielhorn_memi.tex

figures = frontmatter/objective-trace.svg

chapters = spatio-angular.tex

build/objective-trace.pdf: frontmatter/objective-trace.svg
	inkscape frontmatter/objective-trace.svg --export-latex --export-pdf=build/objective-trace.pdf

build/objective-trace.eps: frontmatter/objective-trace.svg
	inkscape frontmatter/objective-trace.svg --export-latex --export-eps=build/objective-trace.eps

build/%.tex: %.tex
	cp $* build/$* 

# find all occurances of \svginput within the tex documents [^%]
# negative character class that ignores latex comments i need to write
# ($$_) instead of $_ (the perl expression for the lines from stdin),
# otherwise make will replace $_ with something
define getsvg
        svgs=`perl -ne 'print (($$_) =~ /^[^%]*svginput\{.*?\}\{(.*?)\}/g); print "\n"' $(chapters)`
endef 

echosvg:
	$(getsvg); echo $$svgs


build/memi-simple.eps_tex: svg/memi-simple.svg
	echo inkscape $< --export-latex --export-eps=build/$<

build/kielhorn_memi.pdf: build/$(latexfile) build/$(chapters) build/objective-trace.pdf
	rubber --pdf --inplace build/$(latexfile)

build/kielhorn_memi.dvi: build/$(latexfile) build/$(chapters) build/objective-trace.eps
	rubber --inplace build/$(latexfile)

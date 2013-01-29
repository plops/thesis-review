all: build/kielhorn_memi.pdf

latexfile = kielhorn_memi.tex

figures = frontmatter/objective-trace.svg

chapters = spatio-angular.tex

build/objective-trace.pdf: frontmatter/objective-trace.svg
	inkscape frontmatter/objective-trace.svg --export-latex --export-pdf=build/objective-trace.pdf

build/%: $(chapters) $(latexfile)
	cp $* build/$* 

build/kielhorn_memi.pdf: build/$(latexfile) build/$(chapters) build/objective-trace.pdf
	rubber --pdf --inplace build/$(latexfile)

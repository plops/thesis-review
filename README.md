A current version of the PDF can be accessed here:
https://www.dropbox.com/s/d0f21mtrt8rippe/kielhorn_thesis_20130501.pdf

In order to generate the PDF from the source, the following software is necessary:
texlive
Inkscape 0.48.2 r9819 (Nov 14 2011)
gnuplot 4.4 patchlevel 0

checklist

* grep Warning build/*.log, check that no references are unresolved
* check that the nomenclature has been generated
* run bibtex and look at errors, no journal names should be missing
* check that there are no 'error' question marks in pdf
* widefield, search for occurances of wide\nfield


.RECIPEPREFIX = >
.DELETE_ON_ERROR :
.PRECIOUS : data-all-records enwiki-20130102-pages-articles.xml
.PHONY : all clean data dataclean report dist
.DEFAULT : all

data_files = data-sample-records data-all-records enwiki-20130102-pages-articles.xml

prog_files = exe-analysis-make-2d-plots.py exe-analysis-make-3d-plots.py \
exe-analysis-summary-stats.py exe-wiki-parse-wikipedia.py \
exe-wiki-random-sample.py

img_files = img-scaled-plot.png img-unscaled-plot.png \
img-two-hist-plot.png img-three-hist-plot.png img-contour-plot.png

all : report data

clean : 
> -rm -f wikipedia.{aux,log,out,pdf,tex,tex~}
> -rm -f *.zip
> -rm -f $(prog_files)
> -rm -f $(img_files)

data : $(data_files)

dataclean :
> -rm -f enwiki-20130102-pages-articles.xml
> -rm -f data-all-records
> -rm -f data-sample-records

dist : wikipedia.pdf $(data_files) $(prog_files)
> zip Appendix-A-Sample-Data data-sample-records exe-wiki-random-sample.py 
> zip Appendix-B-Summary-Statistics-Code exe-analysis-summary-stats.py 
> zip Appendix-C-Linreg-Figure-Code exe-analysis-make-2d-plots.py 
> zip Appendix-D-Data-Processing-Code exe-wiki-parse-wikipedia.py 
> zip Appendix-E-All-Processed-Data data-all-records 
> zip Appendix-F-Histogram-Figure-Code exe-analysis-make-3d-plots.py 
> zip Source wikipedia.org Makefile 

report : wikipedia.pdf

%.pdf : %.tex
> -pdflatex -interaction nonstopmode $<
> -pdflatex -interaction nonstopmode $<
> -pdflatex -interaction nonstopmode $<

# Um.  That toothpick-ey regex works around a bug in Org-Mode.  I
# can't really explain it here.  The regex differs from the default
# value of org-babel-src-block-regexp in the "??" part of the last
# line.  Normal value is just one "?" there ... which makes the
# exporter accidentally chomp all of the text after the abstract.  Bug
# report has been submitted to the Org-Mode guys.
wikipedia.tex : $(data_files) $(img_files)
> emacs -Q --visit=wikipedia.org --eval "(progn \
(require 'cl) \
(require 'python) \
(require 'org) \
(require 'org-exp) \
(require 'ob) \
(require 'ob-python) \
(require 'ob-sh) \
(require 'ob-latex) \
(setq org-confirm-babel-evaluate nil) \
(setq org-babel-load-languages '((emacs-lisp . t) (latex . t) (python . t) (sh . t))) \
(setq org-babel-src-block-regexp \
      (concat \
       \"^\\\\([ \\t]*\\\\)#\\\\+begin_src[ \\t]+\\\\([^ \\f\\t\\n\\r\\v]+\\\\)[ \\t]*\" \
       \"\\\\([^\\\":\\n]*\\\"[^\\\"\\n*]*\\\"[^\\\":\\n]*\\\\|[^\\\":\\n]*\\\\)\" \
       \"\\\\([^\\n]*\\\\)\\n\" \
       \"\\\\([^\\000]*?\\n\\\\)??[ \\t]*#\\\\+end_src\")))" \
--batch --funcall org-export-as-latex-batch

img-scaled-plot.png img-unscaled-plot.png : exe-analysis-make-2d-plots.py data-sample-records
> ./exe-analysis-make-2d-plots.py

img-two-hist-plot.png img-three-hist-plot.png img-contour-plot.png : exe-analysis-make-3d-plots.py data-all-records
> ./exe-analysis-make-3d-plots.py

data-sample-records : data-all-records exe-wiki-random-sample.py
> ./exe-wiki-random-sample.py --percent 0.001 data-all-records >data-sample-records

# The last-record tracking here approaches "an Aristocrats joke", in the
# colorful words of one blogger.  To explain:

# 1. First, the variable "last_id" is set to the first string of
# numbers in the last line of the record data file.  This will be the
# Article ID of the last article parsed (or 0 if we don't have any
# records yet and need to parse everything).

# 2. A pipeline is set up to read the xml, skip to just past the last
# article parsed, parse the remaining articles, throw away anything
# with zero links, and add everything that's left to the
# "data-all-records" file.
data-all-records : last_id := $(shell [ ! -e data-all-records ] && echo "0" || \
tail -1 data-all-records | grep -o "^[[:digit:]]\+")# Be sure there's no space at the end.

data-all-records : enwiki-20130102-pages-articles.xml
> cat enwiki-20130102-pages-articles.xml | \
if [ $(last_id) == "0" ]; then cat; \
else sed -n -e "/<id>$(last_id)</,$$ p" | { echo "<mediawiki>"; sed -e '1,/<\/page>/ d'; }; \
fi | \
./exe-wiki-parse-wikipedia.py | \
grep -v ":0$$" >>data-all-records

enwiki-20130102-pages-articles.xml : 
> curl -C - -O http://dumps.wikimedia.org/enwiki/20130102/enwiki-20130102-pages-articles.xml.bz2
> bunzip2 enwiki-20130102-pages-articles.xml.bz2

%.py : Makefile
> emacs -Q --batch --visit=wikipedia.org --eval "(progn \
(require 'org) \
(require 'org-exp) \
(require 'ob) \
(require 'ob-tangle) \
(re-search-forward \"^[ \\t]*#\\\\+begin_src[^\\n]*$@\") \
(org-babel-tangle t))"

Makefile : wikipedia.org
> emacs -Q --batch --visit=wikipedia.org --eval "(progn \
(require 'org) \
(require 'org-exp) \
(require 'ob) \
(require 'ob-tangle) \
(re-search-forward \"^[ \\t]*#\\\\+begin_src[^\\n]*$@\") \
(org-babel-tangle t))"
> mv -f wikipedia.makefile Makefile

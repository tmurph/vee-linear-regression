vee-linear-regression
=====================

A project for NEAS Seminars.

I'll add some real documentation here eventually.  For now (taken from the
concluding unscientific postscript):

This report was created from a combination of many freely available open-source
tools.  In the interest of reproducibility, the programs used have been woven
into the report itself, ready to be untangled by others on demand.

The source for the report is available as a =.org= file to be read in the Emacs
text editor, and in theory the entire report can be automatically produced, from
data download through regression analysis to finished =.pdf=, with the use of
=GNU Make=.

"make Makefile; make" might work for you.  If so, please bear in mind
that the code downloads and processes 40+ GB of English Wikipedia
data.  Best run it on an unused laptop with an external harddrive over
a weekend.

In theory.  As the sage once said, in theory there is no difference between
theory and practice, but in practice there is.  The author has made the
following effort to explicitly document which programs are necessary to
reproduce the analysis with no intervention required.  Where appropriate,
required version numbers have been included; more common utility programs are
assumed to work regardless of version.

- Primary programs involved were:
  + =GNU Emacs=, version 24
  + =Python=, version 3
  + =SciPy=, =NumPy=, and =matplotlib= packages for =Python=
  + \LaTeX with full extensions

- Common utility programs employed were:
  + =make=
  + =curl=
  + =bzip2=
  + =grep=
  + =tail=
  + =cat=

Have fun.
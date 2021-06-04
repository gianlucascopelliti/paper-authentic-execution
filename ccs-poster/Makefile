#
# Makefile for acmart package
#
# This file is in public domain
#
# $Id: Makefile,v 1.10 2016/04/14 21:55:57 boris Exp $
#

ISPELLPAT = -ktexskip1 +cref,Cref,url
PACKAGE   = acmart
SAMPLES   = paper.tex

PDF = ${SAMPLES:%.tex=%.pdf}

all:  ${PDF}

paper.zip: ${PDF}
	rm -rf src
	mkdir -p src
	cp Makefile paper.tex ccs.tex acmart.cls ACM-Reference-Format.bst src/
	cp ../bibliography.bib ../acros.tex src/
	cp -r graphics src/
	${MAKE} -C src/
	zip -r paper.zip src/



%.pdf:  %.dtx   $(PACKAGE).cls 
	cp ../bibliography.bib ../acros.tex ./
	pdflatex $<
	- bibtex $*
	pdflatex $<
	- makeindex -s gind.ist -o $*.ind $*.idx
	- makeindex -s gglo.ist -o $*.gls $*.glo
	pdflatex $<
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' $*.log) \
	do pdflatex $<; done

spelling: paper.tex
	ispell -t ${ISPELLPAT} -b -d american -p ../paper.dict $<

acmguide.pdf: $(PACKAGE).dtx $(PACKAGE).cls
	pdflatex -jobname acmguide $(PACKAGE).dtx
	- bibtex acmguide
	pdflatex -jobname acmguide $(PACKAGE).dtx
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' acmguide.log) \
	do 	pdflatex -jobname acmguide $(PACKAGE).dtx; done

%.cls:   %.ins %.dtx  
	pdflatex $<

%.pdf:  %.tex   $(PACKAGE).cls ACM-Reference-Format.bst
	cp ../bibliography.bib ../acros.tex ./
	pdflatex $<
	- bibtex $*
	pdflatex $<
	pdflatex $<
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' $*.log) \
	do pdflatex $<; done

sample-manuscript.pdf \
sample-acmsmall.pdf \
sample-acmlarge.pdf \
sample-acmtog.pdf: samplebody-journals.tex

sample-sigconf.pdf \
sample-sigconf-authordraft.pdf \
sample-sigplan.pdf \
sample-sigchi.pdf: samplebody-conf.tex


.PRECIOUS:  $(PACKAGE).cfg $(PACKAGE).cls


clean:
	$(RM)  *.log *.aux \
	*.cfg *.glo *.idx *.toc \
	*.ilg *.ind *.out *.lof \
	*.lot *.bbl *.blg *.gls *.cut *.hd \
	*.dvi *.ps *.thm *.tgz *.zip *.rpi
	$(RM) bibliography.bib acros.tex
	$(RM) -rf src

distclean: clean
	$(RM) $(PDF) *-converted-to.pdf

#
# Archive for the distribution. Includes typeset documentation
#
archive:  all clean
	tar -C .. -czvf ../$(PACKAGE).tgz --exclude '*~' --exclude '*.tgz' --exclude '*.zip'  --exclude CVS --exclude '.git*' $(PACKAGE); mv ../$(PACKAGE).tgz .

zip:  all clean
	zip -r  $(PACKAGE).zip * -x '*~' -x '*.tgz' -x '*.zip' -x CVS -x 'CVS/*'

ISPELLPAT = -ktexskip1 +cref,Cref,url
MAINTEX   = authentic-execution.tex conclusions.tex discussion.tex \
            evaluation.tex implementation.tex introduction.tex \
            paper.tex related.tex scenario_tcb.tex system-model.tex \
            fig_example.tex fig_example_code.tex acks.tex abstract.tex \
            comparison_table.tex appendix.tex

OTHERTEX  = acros.tex defs.tex header.tex example.tex compiled-pm.tex \
            bibliography.bib microb_sequence.tex aes.tex spongent.tex \
			design-pseudocode.tex microb_rtt.tex microb_update.tex
SUPLEMENT = secargument.tex secargument_text.tex
	
SPELLCHECK= ${MAINTEX} ${SUPLEMENT}
ALLTEX    = ${MAINTEX} ${SUPLEMENT} ${OTHERTEX}
TAR_FILES = ${MAINTEX} ${OTHERTEX} *.sty ccs.xml *.cls *.bst \
			graphics/20210808-scenario.pdf \
			graphics/clipart/moisture-meter.pdf \
			graphics/clipart/tap-drops.pdf \
			listings/appagg.reactive \
			listings/appflo.reactive \
			listings/attest.py \
			listings/handleinput.py \
			listings/handleoutput.py \
			listings/setkey.py \
			listings/descriptor.yaml \
			listings/mflos.c \
			listings/mflos.rs \
			graphics/smart-home.drawio.pdf \
			graphics/trustzone-attestation.drawio.pdf \
			paper.bbl

SRC_FILES = ${MAINTEX} ${OTHERTEX} *.sty ccs.xml *.cls *.bst \
			graphics/Makefile \
			graphics/clipart/Makefile \
			graphics/20210808-scenario.svg \
			graphics/clipart/moisture-meter.svg \
			graphics/clipart/tap-drops.svg \
			listings/appagg.reactive \
			listings/appflo.reactive \
			listings/attest.py \
			listings/handleinput.py \
			listings/handleoutput.py \
			listings/setkey.py \
			listings/descriptor.yaml \
			listings/mflos.c \
			listings/mflos.rs \
			graphics/smart-home.drawio.svg \
			graphics/trustzone-attestation.drawio.svg \
			paper.bbl

all: spelling paper.pdf

paper.pdf: ${MAINTEX} ${OTHERTEX} ${SUPLEMENT}
	${MAKE} -C graphics/clipart/
	${MAKE} -C graphics/
	latexmk -logfilewarnings -logfilewarninglist -pdf paper.tex 

tar: paper.pdf
	tar -czvf paper.tar.gz $(TAR_FILES)

zip: paper.pdf
	zip paper.zip $(TAR_FILES)

zip_src:
	zip src.zip $(SRC_FILES)

pvc:
	latexmk -pdf -pvc paper.tex

spelling: ${SPELLCHECK}
	for file in ${SPELLCHECK}; do \
          ispell -t ${ISPELLPAT} -b -d american -p ./paper.dict $$file; \
        done

clean:
	rm -f *.bak
	rm -f *.aux *.bbl *.bbl *.blg *.ent *.fdb_latexmk *.fls *.log *.out
	rm -f comment.cut paper.synctex.gz

distclean: clean
	${MAKE} -C graphics/clipart/ clean
	rm -f paper.pdf secargument.pdf



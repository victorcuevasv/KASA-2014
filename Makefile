PATH:=$(PATH):/usr/texbin/.:./bin/
DBOX:=$(DBOX)
DIRNAME:= $(shell basename `pwd`)

LATEX=/usr/texbin/latex
BIBTEX=/usr/texbin/bibtex
DVIPS=/usr/texbin/dvips
DVIPDF=dvipdf
PS2PDF=/usr/local/bin/ps2pdf
COMPRESS=bin/compress.sh
UPLOAD_FILE=bin/upload_file.py


TIMESTAMP:=$(shell date +"%Y%m%d.%H%M")
BASENAME:=$(shell basename $(PWD))

MAIN=main
BIB_NAME=library
BIB_DIR=./library
TEX=$(MAIN).tex
AUX=$(MAIN).aux
DVI=$(MAIN).dvi
PS=$(MAIN).ps
PDF=$(MAIN).pdf
PDF2=$(DIRNAME).pdf
PDF_TIMESTAMP=$(DIRNAME).$(TIMESTAMP).pdf
BIB=$(BIB_DIR)/$(BIB_NAME).bib
BIBTMP=$(BIB).tmp
DIFF1=$(BIBTMP).diff
DIFF2=$(BIB).diff

TITLE=title
TITLE_TEX=$(TITLE).tex
TITLE_AUX=$(TITLE).aux
TITLE_DVI=$(TITLE).dvi
TITLE_PS=$(TITLE).ps
TITLE_PDF=$(TITLE).pdf

COMPRESSEDFILE:=$(shell echo "$(BASENAME).$(TIMESTAMP)")

all:: compile pdf

fast:: _latex pdf



title:
	$(LATEX) -interaction=nonstopmode $(TITLE_TEX)
	$(DVIPS) -o $(TITLE_PS) $(TITLE_DVI)
	$(PS2PDF) $(TITLE_PS)
	open $(TITLE_PDF)

_latex:
	$(LATEX) -interaction=nonstopmode $(TEX)

_bibtex:
	$(BIBTEX) $(AUX)

compile:: _latex _latex _bibtex _latex _bibtex _latex 

pdf:
	$(DVIPS) -o $(PS) $(DVI)
	$(PS2PDF) $(PS)
	@mv $(PDF) $(PDF2)
	@cp $(PDF2) $(DBOX)
	open $(PDF2)
pdf2:
	$(DVIPS) -o $(PS) $(DVI)
	$(PS2PDF) $(PS)
	@mv $(PDF) $(PDF2)
	open $(PDF2)
bib:
	@cp $(BIB) $(BIBTMP)
	@sh $(BIB_DIR)/consolidate_bib.sh $(BIB_DIR)/*.bib > $(BIB)
	@cat $(BIBTMP) |grep '^ *@' | sed -e 's/@.*{//' | sed -e 's/, *//' |sort > $(DIFF1)
	@cat $(BIB)    |grep '^ *@' | sed -e 's/@.*{//' | sed -e 's/, *//' |sort > $(DIFF2)
	@diff $(DIFF1) $(DIFF2) | egrep '^(<|>) .' | sort | sed -e 's/>/[new]    /' | sed -e 's/</[dropped]/'
	@rm $(BIBTMP) $(DIFF1) $(DIFF2)
tgz:
	@sh $(COMPRESS) tgz $(COMPRESSEDFILE).tgz
zip:
	@sh $(COMPRESS) zip $(COMPRESSEDFILE).zip

share-zip:
	@sh $(COMPRESS) zip $(COMPRESSEDFILE).zip
	@sh share.sh '../$(COMPRESSEDFILE).zip'

share-tgz:
	@sh $(COMPRESS) tgz $(COMPRESSEDFILE).tgz
	@sh share.sh '../$(COMPRESSEDFILE).tgz'


share-pdf:
	@echo "pdf: "
	@cp $(PDF2) $(PDF_TIMESTAMP)
	@sh share.sh '$(PDF_TIMESTAMP)'
share:
	@sh $(COMPRESS) zip $(COMPRESSEDFILE).zip
	@sh $(COMPRESS) tgz $(COMPRESSEDFILE).tgz
	@echo "pdf: "
	@cp $(PDF2) $(PDF_TIMESTAMP)
	@sh share.sh '$(PDF_TIMESTAMP)'
	@echo "zip: "
	@sh share.sh '../$(COMPRESSEDFILE).zip'
	@echo "tgz: "
	@sh share.sh '../$(COMPRESSEDFILE).tgz'

stats-refs:
	@count.years.sh content/content.tex
clean:
	rm *.aux *.lot *.out *.toc *.bbl *.log *.blg *.lof *.dvi *.ps $(PDF2)


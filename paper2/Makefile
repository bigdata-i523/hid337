FILE=report
FLAGS=-interaction nonstopmode -halt-on-error -file-line-error 
REVIEW=review
DEFAULT=$(FILE)

UNAME := $(shell uname)

ifeq ($(UNAME), Darwin)
OPEN=open
endif
ifeq ($(UNAME), Linux)
OPEN=xdg-open
endif


all:
	pdflatex ${FLAGS} ${FILE}
	bibtex ${FILE}
	pdflatex ${FLAGS} ${FILE}
	pdflatex ${FLAGS} ${FILE}

#review-create:
#	cp -i report.tex review.tex
#	make -f Makefile review-fetch


insert:
	rm  -f bibtex-error.tex
	echo '\\section{Bibtex Issues}' > bibtex-error.tex
	bibtex -terse ${REVIEW} | sed -e 's/^/\\todo[inline]{/'  | sed -e 's/.*/&}/'  >> bibtex-error.tex
	sed 's/^\\end{document}/\\input{bibtex-error}\\input{issues}\\end{document}/g' < ${REVIEW}.tex > tmp.tex
	mv tmp.tex ${REVIEW}.tex
	tail ${REVIEW}.tex

#review-fetch:
#	wget -q https://raw.githubusercontent.com/bigdata-i523/sample-hid000/master/paper1/issues.tex

review:
	rm -rf ~/tmp-review
	mkdir -p ~/tmp-review
	cp -r * ~/tmp-review
	cp report.tex ~/tmp-review/review.tex
	cd ~/tmp-review; make -f Makefile insert
	cd ~/tmp-review; make -f Makefile review-pdf
	cp ~/tmp-review/review.pdf review-local.pdf
	open ${REVIEW}-local.pdf
	rm -rf ~/tmp-review

review-pdf:
	pdflatex ${FLAGS} ${REVIEW}
	bibtex ${REVIEW}
	make -f Makefile insert
	pdflatex ${FLAGS} ${REVIEW}
	bibtex ${REVIEW}
	pdflatex ${FLAGS} ${REVIEW}
	pdflatex ${FLAGS} ${REVIEW}
	bibtex -terse ${REVIEW} | sed -e 's/^/\* [ ] /' 

pack:
	rm -rf ${FILE}
	mkdir ${FILE}
	mkdir ${FILE}/tex
	mkdir ${FILE}/images
	cp ${FILE}.tex ${FILE}
	cp ${FILE}.bib ${FILE}
	cp ${FILE}.pdf ${FILE}
	cp tex/sig-alternate-2013.cls ${FILE}/tex
	cp -r images/*.pdf ${FILE}/images
	tar cvf ${FILE}.tar ${FILE}

clean:
	rm -rf *~ *.aux *.bbl *.dvi *.log *.out *.blg *.pdf *.toc *.fdb_latexmk *.fls *.fff *.lof *.lot *.ttt *.cut
	rm -rf _region_.*

view:
	$(OPEN) ${FILE}.pdf

# all dependce tracking taking care of by Latexmk
fast:
	latexmk -pdf ${FILE}

watch:
	latexmk -pvc -view=pdf ${FILE}

.PHONY: all clean view fast watch

pull:
	git pull

up:
	git commit -a
	git push

#publish:
#	@echo "==============================================================="
#	@echo "publish ${FILE}.pdf -> http://cyberaide.github.io/papers/${FILE}.pdf" 
#	@echo "==============================================================="
#	cp ${FILE}.pdf /tmp
#	cd ..; git checkout gh-pages
#	cp /tmp/${FILE}.pdf .
#	git add ${FILE}.pdf
#	git commit -m "adding new version of ${FILE}.pdf" ${FILE}.pdf
#	git push
#	cd bigdata
#	git checkout master


bib-extract:
	echo "EXTRACTING ALL USED CITATIONS INTO A BIB FILE"
	bibtool -x ${FILE}.aux -o ${FILE}.bib

skim:
	echo $(DEFAULT)
	open -a /Applications/skim.app $(DEFAULT).pdf

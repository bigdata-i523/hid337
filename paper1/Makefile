FILE=report
FLAGS=-interaction nonstopmode -halt-on-error -file-line-error 
REVIEW=review
DEFAULT=$(FILE)
LATEX=pydflatex

UNAME := $(shell uname)

ifeq ($(UNAME), Darwin)
OPEN=open
endif
ifeq ($(UNAME), Linux)
OPEN=xdg-open
endif


simple:
	pdflatex ${FLAGS} ${FILE} 
	make -f Makefile bibtex
	pdflatex ${FLAGS} ${FILE}
	pdflatex ${FLAGS} ${FILE} 


check:
	$(LATEX) ${FILE} > tmp.log 2>&1
	make -f Makefile bibtex > report-latex.log 2>&1
	$(LATEX) ${FILE} > tmp.log 2>&1
	$(LATEX) ${FILE} >> report-latex.log 2>&1
	make -f Makefile quote_error >> report-latex.log 2>&1
	make -f Makefile yaml_error >> report-latex.log 2>&1
	cat report-latex.log



bibtex:
	@echo 
	@echo "bibtext error" 
	@echo "===========================================" 
	@echo 
	@bibtex $(FILE)
	@echo 
	@echo "bibtext _ label error" 
	@echo "===========================================" 
	@echo 
	@fgrep "@" report.bib |fgrep _ | awk -F',' '{print $1}' |  sort -u 
	@echo
	@echo "bibtext space label error"
	@echo "===========================================" 
	@echo
	@fgrep "@" report.bib |fgrep " " | awk -F',' '{print $1}' | fgrep -v "url" | fgrep -v "@String" | fgrep -v "@Comment"|  sort -u
	@echo
	@echo "bibtext comma label error"
	@echo "===========================================" 
	@echo
	@fgrep "@" report.bib | fgrep -v "@String" | fgrep -v "@Comment"| fgrep -v ',' | sort -u 

quote_error:
	@echo
	@echo "latex quote error"
	@echo "====================="
	@echo
	@fgrep @ report.tex | fgrep  '"' |sort -u 

yaml_error:
	@echo
	@echo "yaml error"
	@echo "====================="
	@echo
	@yamllint ../README.yml

#@echo
#./check-yaml.py

#review-create:
#	cp -i report.tex review.tex
#	make -f Makefile review-fetch


insert:
	rm  -f bibtex-error.tex
	@echo '\\section{Bibtex Issues}' > bibtex-error.tex
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
	$(LATEX) ${FLAGS} ${REVIEW}
	bibtex ${REVIEW}
	make -f Makefile insert
	$(LATEX) ${FLAGS} ${REVIEW}
	bibtex ${REVIEW}
	$(LATEX) ${FLAGS} ${REVIEW}
	$(LATEX) ${FLAGS} ${REVIEW}
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

MD=$(wildcard *.md)
#PDF=$(patsubst %.md, %.pdf, $(MD))
PDF=Proposal.pdf
FORMAT=markdown+yaml_metadata_block+startnum+fancy_lists+definition_lists+link_attributes+inline_notes+implicit_figures+smart
GEOM=geometry:margin=1in
TEX=xelatex
all: $(PDF)

%.tex: %.md minhash.bib latex.template
	pandoc -r $(FORMAT) -V $(GEOM) -F pandoc-crossref -s --natbib --template=latex.template $(patsubst %.tex, %.md, $@) -o $@

%.pdf: %.tex
	$(TEX) $(patsubst %.tex, %, $<)
	bibtex $(patsubst %.tex, %.aux, $<)
	$(TEX) $(patsubst %.tex, %, $<)
	cp $< $<.tmp
	$(TEX) $(patsubst %.tex, %, $<)

clean:
	rm -f *.pdf *.bbl *.bcf *.blg *.log *.aux *.out *.run *.xml *.tex
